package nl.spoonpaco.x96launcher;

import android.app.Activity;
import android.content.ActivityNotFoundException;
import android.content.ComponentName;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.content.pm.PackageManager;
import android.content.pm.ResolveInfo;
import android.graphics.Color;
import android.graphics.Typeface;
import android.graphics.drawable.ColorDrawable;
import android.graphics.drawable.Drawable;
import android.graphics.drawable.GradientDrawable;
import android.net.Uri;
import android.os.Bundle;
import android.os.Handler;
import android.os.Looper;
import android.provider.Settings;
import android.util.TypedValue;
import android.view.Gravity;
import android.view.KeyEvent;
import android.view.View;
import android.view.ViewGroup;
import android.widget.FrameLayout;
import android.widget.HorizontalScrollView;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import android.widget.TextView;
import android.widget.Toast;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Locale;
import java.util.Map;

/**
 * X96 Launcher: Netflix-achtig startscherm voor de X96 aan de projector.
 * Bovenin een grote "hero" van de geselecteerde tegel, daaronder rijen tegels.
 * Puur framework-Java, geen bibliotheken: klein en snel op een 32-bit box.
 */
public class MainActivity extends Activity {

    static final int RED = Color.parseColor("#E50914");
    static final int BG = Color.parseColor("#141414");
    static final int CARD = Color.parseColor("#232323");
    static final int GREY = Color.parseColor("#B3B3B3");

    /** Vaste volgorde van de rij "Kijken". Alleen wat geïnstalleerd is, verschijnt. */
    static final String[] WATCH = {
            "org.xbmc.kodi",
            "com.teamsmart.videomanager.tv",
            "com.google.android.youtube.tv",
            "com.google.android.youtube",
            "com.amazon.avod.thirdpartyclient",
            "org.videolan.vlc",
            "com.ionitech.airscreen",
    };

    static final Map<String, String> BLURB = new HashMap<>();
    static {
        BLURB.put("org.xbmc.kodi", "Films en series van de NAS, Elementum, IPTV en Trakt.");
        BLURB.put("com.teamsmart.videomanager.tv", "YouTube zonder reclame.");
        BLURB.put("com.google.android.youtube.tv", "YouTube voor tv.");
        BLURB.put("com.google.android.youtube", "YouTube.");
        BLURB.put("com.amazon.avod.thirdpartyclient", "Prime Video.");
        BLURB.put("org.videolan.vlc", "Speelt elk bestand af, ook van USB of het netwerk.");
        BLURB.put("com.ionitech.airscreen", "Casten vanaf je telefoon (Cast, AirPlay, DLNA).");
        BLURB.put("com.lonelycatgames.Xplore", "Bestanden op de box, USB en het netwerk.");
    }

    static class Tile {
        String label;
        String pkg;
        Drawable banner;   // breed tv-plaatje, kan null zijn
        Drawable icon;
        Intent intent;
        String blurb;
    }

    private final Handler handler = new Handler(Looper.getMainLooper());
    private ImageView heroImage;
    private TextView heroTitle, heroBlurb, clock;
    private LinearLayout rows;
    private ScrollView scroller;
    private View firstTile;

    private final Runnable tick = new Runnable() {
        @Override public void run() {
            clock.setText(new SimpleDateFormat("HH:mm", Locale.getDefault()).format(new Date()));
            handler.postDelayed(this, 15_000);
        }
    };

    @Override
    protected void onCreate(Bundle state) {
        super.onCreate(state);
        setContentView(buildScreen());
    }

    @Override
    protected void onResume() {
        super.onResume();
        fillRows();
        handler.post(tick);
        if (firstTile != null) firstTile.requestFocus();
    }

    @Override
    protected void onPause() {
        super.onPause();
        handler.removeCallbacks(tick);
    }

    /** Als startscherm: terug-knop doet niets. */
    @Override
    public void onBackPressed() {
        scroller.smoothScrollTo(0, 0);
        if (firstTile != null) firstTile.requestFocus();
    }

    // ------------------------------------------------------------------ layout

    private View buildScreen() {
        FrameLayout root = new FrameLayout(this);
        root.setBackgroundColor(Color.BLACK);

        // Hero: achtergrondbeeld van de geselecteerde app, gedimd, met verloop naar zwart.
        heroImage = new ImageView(this);
        heroImage.setScaleType(ImageView.ScaleType.CENTER_CROP);
        heroImage.setAlpha(0.55f);
        FrameLayout.LayoutParams heroLp = new FrameLayout.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT, dp(330), Gravity.TOP | Gravity.END);
        heroLp.leftMargin = dp(260);
        root.addView(heroImage, heroLp);

        View fadeLeft = new View(this);
        fadeLeft.setBackground(new GradientDrawable(GradientDrawable.Orientation.LEFT_RIGHT,
                new int[]{Color.BLACK, Color.BLACK, Color.TRANSPARENT}));
        root.addView(fadeLeft, new FrameLayout.LayoutParams(dp(720), dp(330)));

        View fadeDown = new View(this);
        fadeDown.setBackground(new GradientDrawable(GradientDrawable.Orientation.TOP_BOTTOM,
                new int[]{Color.TRANSPARENT, Color.BLACK}));
        FrameLayout.LayoutParams fdLp = new FrameLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, dp(140));
        fdLp.topMargin = dp(200);
        root.addView(fadeDown, fdLp);

        // Logo + klok
        TextView logo = text("X96", 30, RED, true);
        logo.setLetterSpacing(0.08f);
        FrameLayout.LayoutParams logoLp = new FrameLayout.LayoutParams(-2, -2);
        logoLp.leftMargin = dp(48);
        logoLp.topMargin = dp(24);
        root.addView(logo, logoLp);

        clock = text("", 22, Color.WHITE, false);
        FrameLayout.LayoutParams clockLp = new FrameLayout.LayoutParams(-2, -2, Gravity.TOP | Gravity.END);
        clockLp.rightMargin = dp(48);
        clockLp.topMargin = dp(28);
        root.addView(clock, clockLp);

        // Titel + omschrijving van de geselecteerde tegel
        LinearLayout heroText = new LinearLayout(this);
        heroText.setOrientation(LinearLayout.VERTICAL);
        heroTitle = text("", 44, Color.WHITE, true);
        heroBlurb = text("", 18, GREY, false);
        heroBlurb.setMaxWidth(dp(560));
        heroText.addView(heroTitle);
        heroText.addView(heroBlurb);
        FrameLayout.LayoutParams htLp = new FrameLayout.LayoutParams(-2, -2);
        htLp.leftMargin = dp(48);
        htLp.topMargin = dp(110);
        root.addView(heroText, htLp);

        // Rijen
        scroller = new ScrollView(this);
        scroller.setVerticalScrollBarEnabled(false);
        scroller.setClipToPadding(false);
        rows = new LinearLayout(this);
        rows.setOrientation(LinearLayout.VERTICAL);
        rows.setPadding(0, 0, 0, dp(48));
        scroller.addView(rows);
        FrameLayout.LayoutParams sLp = new FrameLayout.LayoutParams(-1, -1);
        sLp.topMargin = dp(270);
        root.addView(scroller, sLp);

        return root;
    }

    private void fillRows() {
        rows.removeAllViews();
        firstTile = null;

        Map<String, Tile> apps = loadApps();

        List<Tile> watch = new ArrayList<>();
        for (String p : WATCH) if (apps.containsKey(p)) watch.add(apps.get(p));
        // Niet allebei YouTube én de tv-versie tonen.
        if (apps.containsKey("com.google.android.youtube.tv")) watch.remove(apps.get("com.google.android.youtube"));
        addRow("Kijken", watch, true);

        List<Tile> rest = new ArrayList<>(apps.values());
        rest.removeAll(watch);
        Collections.sort(rest, (a, b) -> a.label.compareToIgnoreCase(b.label));
        addRow("Alle apps", rest, false);

        addRow("Systeem", systemTiles(), false);
    }

    private void addRow(String title, List<Tile> tiles, boolean big) {
        if (tiles.isEmpty()) return;

        TextView t = text(title, 20, Color.WHITE, true);
        t.setPadding(dp(48), dp(14), 0, dp(8));
        rows.addView(t);

        HorizontalScrollView hs = new HorizontalScrollView(this);
        hs.setHorizontalScrollBarEnabled(false);
        hs.setClipToPadding(false);
        hs.setClipChildren(false);
        LinearLayout line = new LinearLayout(this);
        line.setPadding(dp(44), dp(10), dp(44), dp(10));
        line.setClipChildren(false);
        hs.addView(line);

        int w = big ? dp(280) : dp(200);
        int h = w * 9 / 16;
        for (Tile tile : tiles) {
            View v = tileView(tile, w, h);
            LinearLayout.LayoutParams lp = new LinearLayout.LayoutParams(w, h);
            lp.setMargins(dp(6), 0, dp(6), 0);
            line.addView(v, lp);
            if (firstTile == null) {
                firstTile = v;
                showHero(tile);
            }
        }
        rows.addView(hs);
    }

    private View tileView(Tile tile, int w, int h) {
        FrameLayout card = new FrameLayout(this);
        card.setFocusable(true);
        card.setClickable(true);
        card.setBackground(rounded(CARD, 0));
        card.setClipToOutline(true);

        if (tile.banner != null) {
            ImageView img = new ImageView(this);
            img.setScaleType(ImageView.ScaleType.CENTER_CROP);
            img.setImageDrawable(tile.banner);
            card.addView(img, new FrameLayout.LayoutParams(-1, -1));
        } else {
            LinearLayout box = new LinearLayout(this);
            box.setOrientation(LinearLayout.VERTICAL);
            box.setGravity(Gravity.CENTER);
            ImageView img = new ImageView(this);
            img.setImageDrawable(tile.icon);
            box.addView(img, new LinearLayout.LayoutParams(h / 2, h / 2));
            TextView l = text(tile.label, 14, Color.WHITE, false);
            l.setSingleLine(true);
            l.setPadding(dp(8), dp(6), dp(8), 0);
            box.addView(l);
            card.addView(box, new FrameLayout.LayoutParams(-1, -1));
        }

        // Rode balk onderin, alleen zichtbaar bij focus (Netflix-accent).
        View bar = new View(this);
        bar.setBackgroundColor(RED);
        bar.setVisibility(View.INVISIBLE);
        card.addView(bar, new FrameLayout.LayoutParams(-1, dp(4), Gravity.BOTTOM));

        card.setOnFocusChangeListener((v, focus) -> {
            v.animate().scaleX(focus ? 1.12f : 1f).scaleY(focus ? 1.12f : 1f)
                    .translationZ(focus ? dp(8) : 0).setDuration(140).start();
            card.setForeground(focus ? rounded(Color.TRANSPARENT, dp(3)) : null);
            bar.setVisibility(focus ? View.VISIBLE : View.INVISIBLE);
            if (focus) showHero(tile);
        });
        card.setOnClickListener(v -> launch(tile));
        card.setOnLongClickListener(v -> {
            if (tile.pkg != null) {
                launch(newTile(null, null, null,
                        new Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS, Uri.parse("package:" + tile.pkg)), null));
            }
            return true;
        });
        card.setOnKeyListener((v, code, ev) -> {
            if (ev.getAction() == KeyEvent.ACTION_UP && code == KeyEvent.KEYCODE_MENU && tile.pkg != null) {
                v.performLongClick();
                return true;
            }
            return false;
        });
        return card;
    }

    private void showHero(Tile tile) {
        heroTitle.setText(tile.label);
        heroBlurb.setText(tile.blurb != null ? tile.blurb : "");
        Drawable d = tile.banner != null ? tile.banner : tile.icon;
        heroImage.setImageDrawable(d != null ? d.getConstantState() != null
                ? d.getConstantState().newDrawable().mutate() : d : new ColorDrawable(BG));
    }

    // ------------------------------------------------------------------ apps

    private Map<String, Tile> loadApps() {
        PackageManager pm = getPackageManager();
        Map<String, Tile> out = new LinkedHashMap<>();
        collect(pm, Intent.CATEGORY_LEANBACK_LAUNCHER, out);
        collect(pm, Intent.CATEGORY_LAUNCHER, out);
        return out;
    }

    private void collect(PackageManager pm, String category, Map<String, Tile> out) {
        Intent q = new Intent(Intent.ACTION_MAIN).addCategory(category);
        for (ResolveInfo ri : pm.queryIntentActivities(q, 0)) {
            ActivityInfo ai = ri.activityInfo;
            if (ai == null || getPackageName().equals(ai.packageName) || out.containsKey(ai.packageName)) continue;
            Intent launch = new Intent(Intent.ACTION_MAIN).addCategory(category)
                    .setComponent(new ComponentName(ai.packageName, ai.name))
                    .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_RESET_TASK_IF_NEEDED);
            Drawable banner = ai.loadBanner(pm);
            if (banner == null) banner = ai.applicationInfo.loadBanner(pm);
            out.put(ai.packageName, newTile(ri.loadLabel(pm).toString(), ai.packageName,
                    banner, launch, ri.loadIcon(pm)));
        }
    }

    private List<Tile> systemTiles() {
        List<Tile> list = new ArrayList<>();
        Drawable gear = getDrawable(android.R.drawable.ic_menu_preferences);
        list.add(newTile("Instellingen", null, null,
                new Intent(Settings.ACTION_SETTINGS).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK), gear));
        list.add(newTile("Wifi", null, null,
                new Intent(Settings.ACTION_WIFI_SETTINGS).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK),
                getDrawable(android.R.drawable.ic_menu_share)));
        list.add(newTile("Opslag", null, null,
                new Intent(Settings.ACTION_INTERNAL_STORAGE_SETTINGS).addFlags(Intent.FLAG_ACTIVITY_NEW_TASK),
                getDrawable(android.R.drawable.ic_menu_save)));
        return list;
    }

    private Tile newTile(String label, String pkg, Drawable banner, Intent intent, Drawable icon) {
        Tile t = new Tile();
        t.label = label;
        t.pkg = pkg;
        t.banner = banner;
        t.intent = intent;
        t.icon = icon;
        t.blurb = pkg != null ? BLURB.get(pkg) : null;
        return t;
    }

    private void launch(Tile tile) {
        try {
            startActivity(tile.intent);
        } catch (ActivityNotFoundException | SecurityException e) {
            Toast.makeText(this, "Kan niet openen: " + tile.label, Toast.LENGTH_SHORT).show();
        }
    }

    // ------------------------------------------------------------------ helpers

    private TextView text(String s, int sp, int color, boolean bold) {
        TextView t = new TextView(this);
        t.setText(s);
        t.setTextColor(color);
        t.setTextSize(TypedValue.COMPLEX_UNIT_SP, sp);
        t.setTypeface(Typeface.create("sans-serif", bold ? Typeface.BOLD : Typeface.NORMAL));
        return t;
    }

    private GradientDrawable rounded(int fill, int strokePx) {
        GradientDrawable g = new GradientDrawable();
        g.setColor(fill);
        g.setCornerRadius(dp(6));
        if (strokePx > 0) g.setStroke(strokePx, Color.WHITE);
        return g;
    }

    private int dp(int v) {
        return Math.round(v * getResources().getDisplayMetrics().density);
    }
}
