import AsyncStorage from "@react-native-async-storage/async-storage";
import * as Notifications from "expo-notifications";
import { StatusBar } from "expo-status-bar";
import { useEffect, useMemo, useState } from "react";
import {
  Alert,
  FlatList,
  Pressable,
  SafeAreaView,
  ScrollView,
  Share,
  StyleSheet,
  Switch,
  Text,
  TextInput,
  View
} from "react-native";

import { CATEGORIES } from "./data/categories";
import { QUOTES } from "./data/quotes";

const STORAGE_KEY = "inspiracion-dia-native-state";
const DAILY_NOTIFICATION_ID_KEY = "inspiracion-dia-daily-notification-id";
const DEFAULT_STATE = {
  favorites: [],
  selectedCategory: "hoy",
  reminderEnabled: false,
  reminderTime: "09:00"
};

Notifications.setNotificationHandler({
  handleNotification: async () => ({
    shouldPlaySound: false,
    shouldSetBadge: false,
    shouldShowBanner: true,
    shouldShowList: true
  })
});

export default function App() {
  const [state, setState] = useState(DEFAULT_STATE);
  const [activeTab, setActiveTab] = useState("today");
  const [loaded, setLoaded] = useState(false);

  useEffect(() => {
    AsyncStorage.getItem(STORAGE_KEY)
      .then((raw) => {
        if (raw) setState({ ...DEFAULT_STATE, ...JSON.parse(raw) });
      })
      .finally(() => setLoaded(true));
  }, []);

  useEffect(() => {
    if (!loaded) return;
    AsyncStorage.setItem(STORAGE_KEY, JSON.stringify(state));
  }, [loaded, state]);

  const todayQuote = useMemo(() => getQuoteForToday(), []);
  const selectedCategory = CATEGORIES.find((category) => category.id === state.selectedCategory) || CATEGORIES[0];
  const favoriteSet = useMemo(() => new Set(state.favorites), [state.favorites]);
  const visibleQuotes = useMemo(() => {
    if (state.selectedCategory === "hoy") return QUOTES;
    return QUOTES.filter((quote) => quote.category === state.selectedCategory);
  }, [state.selectedCategory]);

  function updateState(patch) {
    setState((current) => ({ ...current, ...patch }));
  }

  function toggleFavorite(id) {
    setState((current) => {
      const exists = current.favorites.includes(id);
      return {
        ...current,
        favorites: exists
          ? current.favorites.filter((favoriteId) => favoriteId !== id)
          : [...current.favorites, id]
      };
    });
  }

  async function shareQuote(quote) {
    await Share.share({
      message: `${quote.text}\n\nInspiracion Dia`
    });
  }

  async function saveReminder(enabled = state.reminderEnabled, time = state.reminderTime) {
    const cleanTime = normalizeTime(time);
    if (enabled) {
      const permission = await Notifications.requestPermissionsAsync();
      if (!permission.granted) {
        Alert.alert("Notificaciones", "Activa las notificaciones para recibir tu frase diaria.");
        updateState({ reminderEnabled: false, reminderTime: cleanTime });
        return;
      }
      await scheduleDailyReminder(cleanTime);
      updateState({ reminderEnabled: true, reminderTime: cleanTime });
      Alert.alert("Listo", `Recibiras una frase cada dia a las ${cleanTime}.`);
      return;
    }

    await cancelDailyReminder();
    updateState({ reminderEnabled: false, reminderTime: cleanTime });
  }

  async function sendTestNotification() {
    const permission = await Notifications.requestPermissionsAsync();
    if (!permission.granted) {
      Alert.alert("Notificaciones", "Primero permite las notificaciones.");
      return;
    }
    await Notifications.scheduleNotificationAsync({
      content: {
        title: "Tu inspiracion de hoy",
        body: todayQuote.text
      },
      trigger: null
    });
  }

  function renderToday() {
    return (
      <ScrollView contentContainerStyle={styles.scrollContent} showsVerticalScrollIndicator={false}>
        <Header title="Inspiracion Dia" subtitle={formatToday()} />

        <View style={[styles.heroCard, { backgroundColor: getCategory(todayQuote.category).softColor }]}>
          <Text style={[styles.heroCategory, { color: getCategory(todayQuote.category).color }]}>
            {getCategory(todayQuote.category).name}
          </Text>
          <Text style={styles.heroQuote}>{todayQuote.text}</Text>
          <View style={styles.heroActions}>
            <Pressable style={styles.primaryButton} onPress={() => toggleFavorite(todayQuote.id)}>
              <Text style={styles.primaryButtonText}>
                {favoriteSet.has(todayQuote.id) ? "Guardada" : "Guardar"}
              </Text>
            </Pressable>
            <Pressable style={styles.roundButton} onPress={() => shareQuote(todayQuote)}>
              <Text style={styles.roundButtonText}>Enviar</Text>
            </Pressable>
          </View>
        </View>

        <View style={styles.reminderCard}>
          <View style={styles.reminderText}>
            <Text style={styles.cardTitle}>Una notificacion al dia</Text>
            <Text style={styles.cardSubtitle}>
              {state.reminderEnabled ? `Activa a las ${state.reminderTime}` : "Desactivada"}
            </Text>
          </View>
          <Switch value={state.reminderEnabled} onValueChange={(value) => saveReminder(value)} />
        </View>

        <Text style={styles.sectionTitle}>Categorias</Text>
        <CategoryStrip
          selected={state.selectedCategory}
          onSelect={(categoryId) => {
            updateState({ selectedCategory: categoryId });
            setActiveTab("cards");
          }}
        />
      </ScrollView>
    );
  }

  function renderCards() {
    return (
      <View style={styles.screen}>
        <Header title="Tarjetitas" subtitle={selectedCategory.description} />
        <CategoryStrip selected={state.selectedCategory} onSelect={(categoryId) => updateState({ selectedCategory: categoryId })} />
        <FlatList
          data={visibleQuotes}
          keyExtractor={(item) => item.id}
          contentContainerStyle={styles.listContent}
          showsVerticalScrollIndicator={false}
          renderItem={({ item }) => {
            const category = getCategory(item.category);
            return (
              <View style={[styles.quoteCard, { backgroundColor: category.softColor }]}>
                <Text style={[styles.quoteCategory, { color: category.color }]}>{category.name}</Text>
                <Text style={styles.quoteText}>{item.text}</Text>
                <View style={styles.cardActions}>
                  <Pressable style={styles.textButton} onPress={() => toggleFavorite(item.id)}>
                    <Text style={[styles.textButtonLabel, favoriteSet.has(item.id) && { color: "#FF6B57" }]}>
                      {favoriteSet.has(item.id) ? "Guardada" : "Guardar"}
                    </Text>
                  </Pressable>
                  <Pressable style={styles.textButton} onPress={() => shareQuote(item)}>
                    <Text style={styles.textButtonLabel}>Compartir</Text>
                  </Pressable>
                </View>
              </View>
            );
          }}
        />
      </View>
    );
  }

  function renderSettings() {
    return (
      <ScrollView contentContainerStyle={styles.scrollContent} showsVerticalScrollIndicator={false}>
        <Header title="Ajustes" subtitle="Recordatorio diario nativo" />
        <View style={styles.settingsCard}>
          <View style={styles.settingRow}>
            <View style={styles.reminderText}>
              <Text style={styles.cardTitle}>Notificacion diaria</Text>
              <Text style={styles.cardSubtitle}>Solo una frase bonita cada dia.</Text>
            </View>
            <Switch value={state.reminderEnabled} onValueChange={(value) => saveReminder(value)} />
          </View>

          <View style={styles.timeBlock}>
            <Text style={styles.label}>Hora</Text>
            <TextInput
              value={state.reminderTime}
              onChangeText={(value) => updateState({ reminderTime: value })}
              onBlur={() => updateState({ reminderTime: normalizeTime(state.reminderTime) })}
              keyboardType="numbers-and-punctuation"
              placeholder="09:00"
              maxLength={5}
              style={styles.timeInput}
            />
          </View>

          <Pressable style={styles.primaryButtonFull} onPress={() => saveReminder(state.reminderEnabled, state.reminderTime)}>
            <Text style={styles.primaryButtonText}>Guardar recordatorio</Text>
          </Pressable>
          <Pressable style={styles.secondaryButtonFull} onPress={sendTestNotification}>
            <Text style={styles.secondaryButtonText}>Probar notificacion</Text>
          </Pressable>
        </View>
      </ScrollView>
    );
  }

  return (
    <SafeAreaView style={styles.safeArea}>
      <StatusBar style="dark" />
      <View style={styles.container}>
        {activeTab === "today" && renderToday()}
        {activeTab === "cards" && renderCards()}
        {activeTab === "settings" && renderSettings()}
      </View>
      <View style={styles.tabbar}>
        <TabButton label="Hoy" active={activeTab === "today"} onPress={() => setActiveTab("today")} />
        <TabButton label="Tarjetas" active={activeTab === "cards"} onPress={() => setActiveTab("cards")} />
        <TabButton label="Ajustes" active={activeTab === "settings"} onPress={() => setActiveTab("settings")} />
      </View>
    </SafeAreaView>
  );
}

function Header({ title, subtitle }) {
  return (
    <View style={styles.header}>
      <Text style={styles.title}>{title}</Text>
      <Text style={styles.subtitle}>{subtitle}</Text>
    </View>
  );
}

function CategoryStrip({ selected, onSelect }) {
  return (
    <ScrollView horizontal showsHorizontalScrollIndicator={false} contentContainerStyle={styles.categoryStrip}>
      {CATEGORIES.map((category) => {
        const active = category.id === selected;
        return (
          <Pressable
            key={category.id}
            style={[
              styles.categoryChip,
              { backgroundColor: active ? category.color : category.softColor }
            ]}
            onPress={() => onSelect(category.id)}
          >
            <Text style={[styles.categoryChipText, { color: active ? "#FFFFFF" : category.color }]}>
              {category.name}
            </Text>
          </Pressable>
        );
      })}
    </ScrollView>
  );
}

function TabButton({ label, active, onPress }) {
  return (
    <Pressable style={styles.tabButton} onPress={onPress}>
      <View style={[styles.tabDot, active && styles.tabDotActive]} />
      <Text style={[styles.tabLabel, active && styles.tabLabelActive]}>{label}</Text>
    </Pressable>
  );
}

function getQuoteForToday() {
  const now = new Date();
  const start = new Date(now.getFullYear(), 0, 0);
  const day = Math.floor((now - start) / 86400000);
  return QUOTES[day % QUOTES.length];
}

function getCategory(id) {
  return CATEGORIES.find((category) => category.id === id) || CATEGORIES[0];
}

function formatToday() {
  return new Intl.DateTimeFormat("es", {
    weekday: "long",
    day: "numeric",
    month: "long"
  }).format(new Date());
}

function normalizeTime(value) {
  const match = /^(\d{1,2}):?(\d{2})$/.exec(value.trim());
  if (!match) return "09:00";
  const hours = Math.min(23, Math.max(0, Number(match[1])));
  const minutes = Math.min(59, Math.max(0, Number(match[2])));
  return `${String(hours).padStart(2, "0")}:${String(minutes).padStart(2, "0")}`;
}

async function scheduleDailyReminder(time) {
  await cancelDailyReminder();
  const [hour, minute] = time.split(":").map(Number);
  const quote = getQuoteForToday();
  const id = await Notifications.scheduleNotificationAsync({
    content: {
      title: "Tu inspiracion de hoy",
      body: quote.text
    },
    trigger: {
      type: Notifications.SchedulableTriggerInputTypes.DAILY,
      hour,
      minute
    }
  });
  await AsyncStorage.setItem(DAILY_NOTIFICATION_ID_KEY, id);
}

async function cancelDailyReminder() {
  const id = await AsyncStorage.getItem(DAILY_NOTIFICATION_ID_KEY);
  if (id) {
    await Notifications.cancelScheduledNotificationAsync(id);
    await AsyncStorage.removeItem(DAILY_NOTIFICATION_ID_KEY);
  }
}

const styles = StyleSheet.create({
  safeArea: {
    flex: 1,
    backgroundColor: "#F8FBFF"
  },
  container: {
    flex: 1,
    paddingHorizontal: 20
  },
  screen: {
    flex: 1,
    paddingTop: 18
  },
  scrollContent: {
    paddingTop: 18,
    paddingBottom: 112
  },
  header: {
    marginBottom: 22
  },
  title: {
    color: "#172033",
    fontSize: 34,
    fontWeight: "800",
    letterSpacing: 0
  },
  subtitle: {
    marginTop: 6,
    color: "#667085",
    fontSize: 16,
    lineHeight: 22
  },
  heroCard: {
    minHeight: 390,
    justifyContent: "center",
    borderRadius: 34,
    padding: 28,
    shadowColor: "#273A58",
    shadowOffset: { width: 0, height: 18 },
    shadowOpacity: 0.15,
    shadowRadius: 28,
    elevation: 7
  },
  heroCategory: {
    alignSelf: "center",
    marginBottom: 20,
    fontSize: 14,
    fontWeight: "900",
    textTransform: "uppercase"
  },
  heroQuote: {
    color: "#172033",
    fontSize: 31,
    fontWeight: "800",
    lineHeight: 39,
    textAlign: "center"
  },
  heroActions: {
    flexDirection: "row",
    justifyContent: "center",
    gap: 12,
    marginTop: 28
  },
  primaryButton: {
    minHeight: 52,
    justifyContent: "center",
    borderRadius: 999,
    paddingHorizontal: 24,
    backgroundColor: "#FF6B57"
  },
  primaryButtonText: {
    color: "#FFFFFF",
    fontSize: 16,
    fontWeight: "800"
  },
  roundButton: {
    minHeight: 52,
    justifyContent: "center",
    borderRadius: 999,
    paddingHorizontal: 20,
    backgroundColor: "#FFFFFF"
  },
  roundButtonText: {
    color: "#172033",
    fontWeight: "800"
  },
  reminderCard: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between",
    marginTop: 18,
    borderRadius: 24,
    padding: 18,
    backgroundColor: "#FFFFFF",
    borderWidth: 1,
    borderColor: "rgba(23, 32, 51, 0.08)"
  },
  reminderText: {
    flex: 1,
    paddingRight: 14
  },
  cardTitle: {
    color: "#172033",
    fontSize: 17,
    fontWeight: "800"
  },
  cardSubtitle: {
    marginTop: 4,
    color: "#667085",
    fontSize: 14,
    lineHeight: 20
  },
  sectionTitle: {
    marginTop: 24,
    marginBottom: 10,
    color: "#172033",
    fontSize: 22,
    fontWeight: "800"
  },
  categoryStrip: {
    gap: 9,
    paddingRight: 20,
    paddingBottom: 14
  },
  categoryChip: {
    minHeight: 40,
    justifyContent: "center",
    borderRadius: 999,
    paddingHorizontal: 16
  },
  categoryChipText: {
    fontSize: 14,
    fontWeight: "800"
  },
  listContent: {
    paddingTop: 8,
    paddingBottom: 112,
    gap: 14
  },
  quoteCard: {
    borderRadius: 24,
    padding: 20,
    borderWidth: 1,
    borderColor: "rgba(23, 32, 51, 0.06)"
  },
  quoteCategory: {
    marginBottom: 12,
    fontSize: 13,
    fontWeight: "900",
    textTransform: "uppercase"
  },
  quoteText: {
    color: "#172033",
    fontSize: 21,
    fontWeight: "750",
    lineHeight: 29
  },
  cardActions: {
    flexDirection: "row",
    gap: 10,
    marginTop: 18
  },
  textButton: {
    minHeight: 38,
    justifyContent: "center",
    borderRadius: 999,
    paddingHorizontal: 14,
    backgroundColor: "rgba(255, 255, 255, 0.65)"
  },
  textButtonLabel: {
    color: "#172033",
    fontWeight: "800"
  },
  settingsCard: {
    borderRadius: 28,
    padding: 20,
    backgroundColor: "#FFFFFF",
    borderWidth: 1,
    borderColor: "rgba(23, 32, 51, 0.08)"
  },
  settingRow: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-between"
  },
  timeBlock: {
    marginTop: 22
  },
  label: {
    marginBottom: 8,
    color: "#667085",
    fontSize: 14,
    fontWeight: "800"
  },
  timeInput: {
    minHeight: 58,
    borderRadius: 18,
    paddingHorizontal: 16,
    color: "#172033",
    backgroundColor: "#F3F7FB",
    fontSize: 28,
    fontWeight: "800"
  },
  primaryButtonFull: {
    minHeight: 54,
    alignItems: "center",
    justifyContent: "center",
    marginTop: 20,
    borderRadius: 999,
    backgroundColor: "#FF6B57"
  },
  secondaryButtonFull: {
    minHeight: 54,
    alignItems: "center",
    justifyContent: "center",
    marginTop: 10,
    borderRadius: 999,
    backgroundColor: "#F3F7FB"
  },
  secondaryButtonText: {
    color: "#172033",
    fontSize: 16,
    fontWeight: "800"
  },
  tabbar: {
    position: "absolute",
    left: 20,
    right: 20,
    bottom: 18,
    flexDirection: "row",
    minHeight: 70,
    borderRadius: 28,
    backgroundColor: "#FFFFFF",
    borderWidth: 1,
    borderColor: "rgba(23, 32, 51, 0.08)",
    shadowColor: "#273A58",
    shadowOffset: { width: 0, height: 14 },
    shadowOpacity: 0.15,
    shadowRadius: 24,
    elevation: 8
  },
  tabButton: {
    flex: 1,
    alignItems: "center",
    justifyContent: "center",
    gap: 6
  },
  tabDot: {
    width: 7,
    height: 7,
    borderRadius: 999,
    backgroundColor: "#CBD5E1"
  },
  tabDotActive: {
    width: 22,
    backgroundColor: "#FF6B57"
  },
  tabLabel: {
    color: "#667085",
    fontSize: 12,
    fontWeight: "800"
  },
  tabLabelActive: {
    color: "#172033"
  }
});
