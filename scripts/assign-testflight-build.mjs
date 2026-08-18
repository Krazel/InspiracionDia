import { createPrivateKey, sign } from "node:crypto";

const required = (name) => {
  const value = process.env[name]?.trim();
  if (!value) throw new Error(`Missing required environment variable: ${name}`);
  return value;
};

const keyId = required("APP_STORE_CONNECT_API_KEY_ID");
const issuerId = required("APP_STORE_CONNECT_ISSUER_ID");
const privateKey = Buffer.from(required("APP_STORE_CONNECT_API_KEY_BASE64"), "base64").toString("utf8");
const appId = required("APP_STORE_CONNECT_APP_ID");
const buildNumber = required("TESTFLIGHT_BUILD_NUMBER");
const groupName = required("TESTFLIGHT_INTERNAL_GROUP");

if (!/^[1-9][0-9]*$/.test(buildNumber)) {
  throw new Error("TESTFLIGHT_BUILD_NUMBER must be a positive integer.");
}

const base64url = (value) => Buffer.from(value).toString("base64url");
const makeToken = () => {
  const now = Math.floor(Date.now() / 1000);
  const header = base64url(JSON.stringify({ alg: "ES256", kid: keyId, typ: "JWT" }));
  const payload = base64url(JSON.stringify({
    iss: issuerId,
    iat: now,
    exp: now + 20 * 60,
    aud: "appstoreconnect-v1",
  }));
  const unsigned = `${header}.${payload}`;
  const signature = sign("sha256", Buffer.from(unsigned), {
    key: createPrivateKey(privateKey),
    dsaEncoding: "ieee-p1363",
  });
  return `${unsigned}.${signature.toString("base64url")}`;
};

const api = async (path, { method = "GET", body } = {}) => {
  const response = await fetch(`https://api.appstoreconnect.apple.com${path}`, {
    method,
    headers: {
      Authorization: `Bearer ${makeToken()}`,
      ...(body ? { "Content-Type": "application/json" } : {}),
    },
    body: body ? JSON.stringify(body) : undefined,
  });
  const text = await response.text();
  if (!response.ok) {
    throw new Error(`App Store Connect ${method} ${path} failed (${response.status}): ${text}`);
  }
  return text ? JSON.parse(text) : null;
};

const sleep = (milliseconds) => new Promise((resolve) => setTimeout(resolve, milliseconds));

const buildPath = () => {
  const params = new URLSearchParams({
    "filter[app]": appId,
    "filter[version]": buildNumber,
    "fields[builds]": "version,uploadedDate,processingState",
    sort: "-uploadedDate",
    limit: "10",
  });
  return `/v1/builds?${params}`;
};

let build;
for (let attempt = 1; attempt <= 40; attempt += 1) {
  const response = await api(buildPath());
  build = response.data.find(({ attributes }) => attributes.version === buildNumber);
  const state = build?.attributes?.processingState;
  if (state === "VALID") break;
  if (state === "FAILED" || state === "INVALID") {
    throw new Error(`Build ${buildNumber} finished processing as ${state}.`);
  }
  console.log(`Build ${buildNumber} is ${state ?? "not visible yet"}; waiting for Apple processing (${attempt}/40).`);
  await sleep(30_000);
}

if (!build || build.attributes.processingState !== "VALID") {
  throw new Error(`Build ${buildNumber} did not become VALID within 20 minutes.`);
}

const groupParams = new URLSearchParams({
  "fields[betaGroups]": "name,isInternalGroup,hasAccessToAllBuilds",
  limit: "200",
});
const groups = await api(`/v1/apps/${encodeURIComponent(appId)}/betaGroups?${groupParams}`);
const group = groups.data.find(({ attributes }) => (
  attributes.name === groupName && attributes.isInternalGroup === true
));

if (!group) {
  throw new Error(`Internal TestFlight group not found: ${groupName}`);
}

const assignedPath = () => {
  const params = new URLSearchParams({
    "fields[builds]": "version,processingState",
    limit: "200",
  });
  return `/v1/betaGroups/${encodeURIComponent(group.id)}/builds?${params}`;
};

const isAssigned = async () => {
  const response = await api(assignedPath());
  return response.data.some(({ id, attributes }) => (
    id === build.id && attributes.version === buildNumber && attributes.processingState === "VALID"
  ));
};

let verified = await isAssigned();
if (!verified && !group.attributes.hasAccessToAllBuilds) {
  await api(`/v1/builds/${encodeURIComponent(build.id)}/relationships/betaGroups`, {
    method: "POST",
    body: { data: [{ type: "betaGroups", id: group.id }] },
  });
  verified = await isAssigned();
}

if (!verified) {
  throw new Error(`Build ${buildNumber} is not visible in internal group ${groupName} after assignment.`);
}

console.log(`Build ${buildNumber} is VALID and assigned to internal group ${groupName}.`);
