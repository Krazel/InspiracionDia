package com.dmkr.inspiraciondia;

import android.Manifest;
import android.app.AlarmManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.graphics.Color;
import android.graphics.Typeface;
import android.os.Build;
import android.os.Bundle;
import android.provider.Settings;
import android.view.Gravity;
import android.view.View;
import android.widget.Button;
import android.widget.FrameLayout;
import android.widget.GridLayout;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import android.widget.Switch;
import android.widget.TextView;
import android.widget.TimePicker;
import android.widget.Toast;

import org.json.JSONArray;
import org.json.JSONObject;

import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.HashSet;
import java.util.Locale;
import java.util.Set;

public class MainActivity extends android.app.Activity {
    private static final String PREFS = "inspiracion_dia";
    private static final String GOLD = "#A87927";
    private static final String INK = "#18130D";
    private static final String CREAM = "#F7F2E9";
    private final ArrayList<Category> categories = new ArrayList<>();
    private final ArrayList<Quote> quotes = new ArrayList<>();
    private SharedPreferences prefs;
    private Quote currentQuote;
    private String selectedCategory = "disciplina";
    private LinearLayout root;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        prefs = getSharedPreferences(PREFS, MODE_PRIVATE);
        selectedCategory = prefs.getString("selectedCategory", "disciplina");
        loadContent();
        currentQuote = quoteForToday();
        showHome();
    }

    private void showHome() {
        root = baseRoot();
        TextView date = label(capitalizedDate(), 14, GOLD);
        TextView title = label("Tu inspiracion de hoy", 28, INK);
        title.setTypeface(Typeface.create(Typeface.SERIF, Typeface.NORMAL));
        root.addView(date);
        root.addView(title);
        root.addView(separator());
        root.addView(cardView());
        root.addView(navBar(0));
        setContentView(wrap(root));
    }

    private View cardView() {
        FrameLayout card = new FrameLayout(this);
        LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(-1, dp(470));
        lp.setMargins(dp(22), dp(18), dp(22), dp(24));
        card.setLayoutParams(lp);
        card.setBackgroundColor(Color.WHITE);
        card.setClipToOutline(true);

        ImageView image = new ImageView(this);
        image.setImageResource(R.drawable.premium_mountains);
        image.setScaleType(ImageView.ScaleType.CENTER_CROP);
        FrameLayout.LayoutParams imageLp = new FrameLayout.LayoutParams(-1, dp(185), Gravity.BOTTOM);
        card.addView(image, imageLp);

        LinearLayout content = new LinearLayout(this);
        content.setOrientation(LinearLayout.VERTICAL);
        content.setGravity(Gravity.CENTER_HORIZONTAL);
        content.setPadding(dp(22), dp(30), dp(22), dp(24));
        card.addView(content, new FrameLayout.LayoutParams(-1, -1));

        TextView quoteMark = label("“", 48, GOLD);
        quoteMark.setTypeface(Typeface.DEFAULT_BOLD);
        TextView quote = label(currentQuote.text, 28, INK);
        quote.setGravity(Gravity.CENTER);
        quote.setLineSpacing(dp(3), 1.0f);
        quote.setTypeface(Typeface.create(Typeface.SERIF, Typeface.NORMAL));
        TextView cat = pill(categoryName(currentQuote.category));
        content.addView(quoteMark);
        content.addView(quote);
        content.addView(separator());
        content.addView(cat);

        LinearLayout actions = new LinearLayout(this);
        actions.setGravity(Gravity.CENTER);
        actions.setOrientation(LinearLayout.HORIZONTAL);
        FrameLayout.LayoutParams actionLp = new FrameLayout.LayoutParams(-1, dp(80), Gravity.BOTTOM);
        actionLp.setMargins(dp(18), 0, dp(18), dp(18));
        card.addView(actions, actionLp);

        Button fav = circleButton(isFavorite(currentQuote.id) ? "♥" : "♡");
        fav.setOnClickListener(v -> {
            toggleFavorite(currentQuote.id);
            showHome();
        });
        Button share = circleButton("↗");
        share.setOnClickListener(v -> shareQuote(currentQuote.text));
        actions.addView(fav);
        Space(actions, dp(140));
        actions.addView(share);
        return card;
    }

    private void showCategories() {
        root = baseRoot();
        TextView title = label("Categorias", 28, INK);
        title.setTypeface(Typeface.create(Typeface.SERIF, Typeface.NORMAL));
        root.addView(title);
        root.addView(separator());

        GridLayout grid = new GridLayout(this);
        grid.setColumnCount(3);
        LinearLayout.LayoutParams gridLp = new LinearLayout.LayoutParams(-1, -2);
        gridLp.setMargins(dp(18), dp(16), dp(18), dp(24));
        grid.setLayoutParams(gridLp);

        for (Category category : categories) {
            TextView item = label(iconFor(category.id) + "\n" + category.name, 16, INK);
            item.setGravity(Gravity.CENTER);
            item.setBackgroundColor(Color.WHITE);
            item.setPadding(dp(8), dp(14), dp(8), dp(14));
            GridLayout.LayoutParams itemLp = new GridLayout.LayoutParams();
            itemLp.width = dp(104);
            itemLp.height = dp(108);
            itemLp.setMargins(dp(5), dp(6), dp(5), dp(8));
            grid.addView(item, itemLp);
            item.setOnClickListener(v -> {
                selectedCategory = category.id;
                prefs.edit().putString("selectedCategory", selectedCategory).apply();
                currentQuote = quoteForCategory(selectedCategory);
                showHome();
            });
        }

        root.addView(grid);
        root.addView(navBar(1));
        setContentView(wrap(root));
    }

    private void showSettings() {
        root = baseRoot();
        TextView title = label("Ajustes", 26, INK);
        title.setGravity(Gravity.LEFT);
        root.addView(title);

        LinearLayout row = new LinearLayout(this);
        row.setOrientation(LinearLayout.HORIZONTAL);
        row.setGravity(Gravity.CENTER_VERTICAL);
        row.setPadding(dp(22), dp(22), dp(22), dp(12));
        TextView text = label("Notificacion diaria", 22, INK);
        Switch enabled = new Switch(this);
        enabled.setChecked(prefs.getBoolean("notifications", false));
        row.addView(text, new LinearLayout.LayoutParams(0, -2, 1));
        row.addView(enabled);
        root.addView(row);

        TimePicker picker = new TimePicker(this);
        picker.setIs24HourView(true);
        picker.setHour(prefs.getInt("hour", 7));
        picker.setMinute(prefs.getInt("minute", 30));
        root.addView(picker, new LinearLayout.LayoutParams(-1, dp(210)));

        Button test = new Button(this);
        test.setText("Enviar prueba");
        test.setTextColor(Color.WHITE);
        test.setBackgroundColor(Color.parseColor(GOLD));
        root.addView(test, margins(-1, dp(50), 28, 10, 28, 10));

        enabled.setOnCheckedChangeListener((buttonView, checked) -> {
            prefs.edit()
                .putBoolean("notifications", checked)
                .putInt("hour", picker.getHour())
                .putInt("minute", picker.getMinute())
                .apply();
            if (checked) scheduleDailyNotification();
            else cancelDailyNotification();
        });
        picker.setOnTimeChangedListener((view, hourOfDay, minute) -> {
            prefs.edit().putInt("hour", hourOfDay).putInt("minute", minute).apply();
            if (prefs.getBoolean("notifications", false)) scheduleDailyNotification();
        });
        test.setOnClickListener(v -> DailyInspirationReceiver.showNotification(this, currentQuote.text));

        TextView preview = label("Vista previa: Inspiracion Dia\nTu frase de hoy ya esta lista.", 15, "#635A50");
        preview.setBackgroundColor(Color.WHITE);
        preview.setPadding(dp(22), dp(18), dp(22), dp(18));
        root.addView(preview, margins(-1, -2, 26, 28, 26, 0));
        root.addView(navBar(2));
        setContentView(wrap(root));
    }

    private LinearLayout navBar(int selected) {
        LinearLayout nav = new LinearLayout(this);
        nav.setGravity(Gravity.CENTER);
        nav.setOrientation(LinearLayout.HORIZONTAL);
        nav.setPadding(0, dp(10), 0, dp(10));
        String[] labels = {"☼\nHoy", "▦\nCategorias", "♡\nAjustes"};
        for (int i = 0; i < labels.length; i++) {
            TextView item = label(labels[i], 13, i == selected ? GOLD : "#6F6A63");
            item.setGravity(Gravity.CENTER);
            final int index = i;
            item.setOnClickListener(v -> {
                if (index == 0) showHome();
                if (index == 1) showCategories();
                if (index == 2) showSettings();
            });
            nav.addView(item, new LinearLayout.LayoutParams(0, dp(58), 1));
        }
        return nav;
    }

    private LinearLayout baseRoot() {
        LinearLayout layout = new LinearLayout(this);
        layout.setOrientation(LinearLayout.VERTICAL);
        layout.setGravity(Gravity.CENTER_HORIZONTAL);
        layout.setPadding(0, dp(36), 0, 0);
        layout.setBackgroundColor(Color.parseColor(CREAM));
        return layout;
    }

    private ScrollView wrap(LinearLayout content) {
        ScrollView scroll = new ScrollView(this);
        scroll.setFillViewport(true);
        scroll.addView(content);
        return scroll;
    }

    private TextView label(String text, int sp, String color) {
        TextView view = new TextView(this);
        view.setText(text);
        view.setTextSize(sp);
        view.setTextColor(Color.parseColor(color));
        view.setGravity(Gravity.CENTER);
        view.setIncludeFontPadding(true);
        return view;
    }

    private TextView pill(String text) {
        TextView view = label(text, 14, GOLD);
        view.setPadding(dp(18), dp(7), dp(18), dp(7));
        view.setBackgroundColor(Color.parseColor("#EFE3CF"));
        return view;
    }

    private Button circleButton(String text) {
        Button button = new Button(this);
        button.setBackgroundColor(Color.WHITE);
        button.setContentDescription(text);
        button.setText(text);
        button.setTextColor(Color.parseColor(GOLD));
        button.setTextSize(24);
        button.setMinimumWidth(dp(54));
        button.setMinimumHeight(dp(54));
        button.setOnLongClickListener(v -> true);
        return button;
    }

    private View separator() {
        View view = new View(this);
        view.setBackgroundColor(Color.parseColor(GOLD));
        rootSafeAddLayout(view, new LinearLayout.LayoutParams(dp(48), dp(2)));
        return view;
    }

    private void rootSafeAddLayout(View view, LinearLayout.LayoutParams params) {
        params.setMargins(0, dp(12), 0, dp(8));
        view.setLayoutParams(params);
    }

    private LinearLayout.LayoutParams margins(int w, int h, int l, int t, int r, int b) {
        LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(w, h);
        lp.setMargins(dp(l), dp(t), dp(r), dp(b));
        return lp;
    }

    private int dp(int value) {
        return (int) (value * getResources().getDisplayMetrics().density + 0.5f);
    }

    private void Space(LinearLayout layout, int width) {
        View space = new View(this);
        layout.addView(space, new LinearLayout.LayoutParams(width, 1));
    }

    private void loadContent() {
        try {
            InputStream input = getResources().openRawResource(R.raw.content);
            ByteArrayOutputStream output = new ByteArrayOutputStream();
            byte[] buffer = new byte[4096];
            int read;
            while ((read = input.read(buffer)) != -1) output.write(buffer, 0, read);
            JSONObject json = new JSONObject(output.toString(StandardCharsets.UTF_8.name()));
            JSONArray categoryJson = json.getJSONArray("categories");
            for (int i = 0; i < categoryJson.length(); i++) {
                JSONObject item = categoryJson.getJSONObject(i);
                categories.add(new Category(item.getString("id"), item.getString("name")));
            }
            JSONArray quoteJson = json.getJSONArray("quotes");
            for (int i = 0; i < quoteJson.length(); i++) {
                JSONObject item = quoteJson.getJSONObject(i);
                quotes.add(new Quote(item.getString("id"), item.getString("category"), item.getString("text")));
            }
        } catch (Exception e) {
            categories.add(new Category("disciplina", "Disciplina"));
            quotes.add(new Quote("fallback", "disciplina", "La disciplina hoy es la libertad manana."));
        }
    }

    private Quote quoteForToday() {
        ArrayList<Quote> filtered = quotesForCategory(selectedCategory);
        Calendar now = Calendar.getInstance();
        int index = Math.abs(now.get(Calendar.DAY_OF_YEAR) + now.get(Calendar.YEAR)) % filtered.size();
        return filtered.get(index);
    }

    private Quote quoteForCategory(String category) {
        ArrayList<Quote> filtered = quotesForCategory(category);
        return filtered.get(0);
    }

    private ArrayList<Quote> quotesForCategory(String category) {
        ArrayList<Quote> filtered = new ArrayList<>();
        for (Quote quote : quotes) if (quote.category.equals(category)) filtered.add(quote);
        return filtered.isEmpty() ? quotes : filtered;
    }

    private String categoryName(String id) {
        for (Category category : categories) if (category.id.equals(id)) return category.name;
        return id;
    }

    private String iconFor(String id) {
        switch (id) {
            case "foco": return "◎";
            case "calma": return "♧";
            case "disciplina": return "△";
            case "autoestima": return "♙";
            case "gratitud": return "♡";
            case "valentia": return "◇";
            case "habitos": return "□";
            case "creatividad": return "☼";
            case "resiliencia": return "♢";
            case "relaciones": return "♁";
            case "energia": return "ϟ";
            default: return "♧";
        }
    }

    private boolean isFavorite(String id) {
        return prefs.getStringSet("favorites", new HashSet<>()).contains(id);
    }

    private void toggleFavorite(String id) {
        Set<String> current = new HashSet<>(prefs.getStringSet("favorites", new HashSet<>()));
        if (current.contains(id)) current.remove(id);
        else current.add(id);
        prefs.edit().putStringSet("favorites", current).apply();
    }

    private void shareQuote(String quote) {
        Intent send = new Intent(Intent.ACTION_SEND);
        send.setType("text/plain");
        send.putExtra(Intent.EXTRA_TEXT, quote);
        startActivity(Intent.createChooser(send, "Compartir"));
    }

    private void scheduleDailyNotification() {
        if (Build.VERSION.SDK_INT >= 33 && checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) != PackageManager.PERMISSION_GRANTED) {
            requestPermissions(new String[]{Manifest.permission.POST_NOTIFICATIONS}, 10);
        }
        AlarmManager alarmManager = (AlarmManager) getSystemService(Context.ALARM_SERVICE);
        if (Build.VERSION.SDK_INT >= 31 && !alarmManager.canScheduleExactAlarms()) {
            startActivity(new Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM));
            Toast.makeText(this, "Activa alarmas exactas para la notificacion diaria.", Toast.LENGTH_LONG).show();
            return;
        }
        Calendar next = Calendar.getInstance();
        next.set(Calendar.HOUR_OF_DAY, prefs.getInt("hour", 7));
        next.set(Calendar.MINUTE, prefs.getInt("minute", 30));
        next.set(Calendar.SECOND, 0);
        if (next.before(Calendar.getInstance())) next.add(Calendar.DAY_OF_YEAR, 1);
        alarmManager.setRepeating(AlarmManager.RTC_WAKEUP, next.getTimeInMillis(), AlarmManager.INTERVAL_DAY, notificationIntent());
        Toast.makeText(this, "Notificacion diaria preparada.", Toast.LENGTH_SHORT).show();
    }

    private void cancelDailyNotification() {
        ((AlarmManager) getSystemService(Context.ALARM_SERVICE)).cancel(notificationIntent());
    }

    private PendingIntent notificationIntent() {
        return PendingIntent.getBroadcast(
            this,
            40,
            new Intent(this, DailyInspirationReceiver.class),
            PendingIntent.FLAG_UPDATE_CURRENT | PendingIntent.FLAG_IMMUTABLE
        );
    }

    private String capitalizedDate() {
        String raw = java.text.DateFormat.getDateInstance(java.text.DateFormat.FULL, new Locale("es", "ES")).format(Calendar.getInstance().getTime());
        return raw.substring(0, 1).toUpperCase(Locale.ROOT) + raw.substring(1);
    }

    static final class Category {
        final String id;
        final String name;
        Category(String id, String name) {
            this.id = id;
            this.name = name;
        }
    }

    static final class Quote {
        final String id;
        final String category;
        final String text;
        Quote(String id, String category, String text) {
            this.id = id;
            this.category = category;
            this.text = text;
        }
    }
}
