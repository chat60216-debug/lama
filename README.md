# Lama dell'Era Perduta

Prototipo giocabile 3D per Android e PC, offline, realizzato in Godot 4.4.1 con GDScript e grafica 3D procedurale (nessun asset esterno necessario).

## Cosa contiene questa prima build

- Ambientazione iniziale di Aetheria e protagonista Kael, classe **Errante Senza Via**.
- Statistiche RPG, HP, Stamina, Mana, oro, esperienza e livelli.
- Allenamento che migliora Spada e Maestria della Spada.
- Primo ricordo dell'antico **Primo Lama**.
- Primo scontro tattico su griglia contro un Segugio di Ferro.
- Attacco fisico, magia, movimento, difesa, ricompense e salvataggio locale.
- Funziona senza connessione dopo l'installazione.

Questa è una **prima vertical slice**, non ancora il gioco completo descritto nel documento: accademie, gilde, compagni, romance, regioni, boss, questline e finali multipli sono contenuti da sviluppare nelle versioni successive.

## Aprire il progetto

1. Installa Godot **4.4.1 Standard**: https://godotengine.org/download/
2. Estrai lo ZIP.
3. In Godot scegli **Importa** e seleziona `project.godot`.
4. Premi F6/F5 per eseguire.

## Creare l'APK Android in locale

1. In Godot apri **Editor > Gestisci modelli di esportazione** e installa i template per la stessa versione di Godot.
2. Configura Android SDK e Java JDK in **Editor > Impostazioni editor > Esportazione > Android**.
3. Apri **Progetto > Esporta**, seleziona Android e premi **Esporta progetto**.
4. Per test personali usa una build debug. Per distribuire pubblicamente serve una chiave di firma release personale e non va caricata su GitHub.

Il progetto usa renderer **Compatibility / OpenGL**, più adatto a una vasta gamma di telefoni.

## APK automatico tramite GitHub Actions

1. Crea un repository GitHub vuoto.
2. Estrai questo ZIP e carica il contenuto nella radice del repository (non caricare la cartella ZIP dentro un'altra cartella).
3. Vai su **Actions** e abilita i workflow se richiesto.
4. Apri il workflow **Build Android APK**, premi **Run workflow**.
5. Al termine apri l'esecuzione riuscita e scarica l'artifact `Lama-Android-APK`.
6. Estrai l'artifact sul telefono e apri l'APK. Android potrebbe chiedere di consentire l'installazione da quella sorgente.

Il workflow produce un APK **debug** firmato per test, non una release Play Store. L'APK viene generato da GitHub Actions; non è incluso nello ZIP sorgente.

## Controlli

- I pulsanti sullo schermo sono pensati anche per il touch.
- **Allenati** aumenta Spada e Maestria.
- **Ricordi** risveglia il primo frammento.
- **Esplora** avvia il combattimento.
- In battaglia: Muovi, Lama, Dardo arcano, Difesa, Fuga.
- Salva/Carica usa lo spazio privato dell'app sul dispositivo.

## Identificativo Android

`com.chat60216.lamaera`
