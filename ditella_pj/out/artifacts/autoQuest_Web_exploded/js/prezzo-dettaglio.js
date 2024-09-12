document.addEventListener("DOMContentLoaded", function () {
    // contextPath support (JSP dovrebbe definire contextPath globalmente)
    const ctx = (typeof contextPath !== 'undefined') ? contextPath : (window.contextPath || '');

    const prezzoBaseEl = document.getElementById('prezzoBase'); //span con prezzo base dell'auto
    const prezzoDisplay = document.getElementById('prezzoTotaleDisplay'); // elemento div dove viene mostrato il prezzo totale
    const idAutoInput = document.getElementById('idAutoInput'); //input nascosto con ID auto
    const radios = document.querySelectorAll('input[name="idAllestimento"]'); //lista di radio button che rappresentano gli allestimenti disponibili

    // hidden per memorizzare l'id dell'allestimento (se presente)
    const hiddenAllElem = document.getElementById('hiddenIdAllestimento');

    let basePrezzo = 0;
    if (prezzoBaseEl) {
        // Prende il testo del prezzo base (es: "€25.000" o "25000")
        let txt = prezzoBaseEl.textContent || prezzoBaseEl.innerText || '';

        // Rimuove il simbolo euro, spazi non-breaking, punti come separatori migliaia
        txt = txt.replace('€', '').replace(/\u00A0/g, ' ').trim();

        // Se contiene punti come separatori migliaia (es: "25.000")
        if (txt.includes('.') && !txt.includes(',')) {
            // Rimuove i punti separatori migliaia
            txt = txt.replace(/\./g, '');
        }
        // Se contiene virgole come separatore decimale
        else if (txt.includes(',')) {
            txt = txt.replace(',', '.');
        }

        //normalizzazione della stringa fatta, si può convertire il numero per poter fare operazioni aritmetiche
        basePrezzo = parseFloat(txt) || 0;
        console.log("Prezzo base estratto:", basePrezzo, "da testo:", prezzoBaseEl.textContent);
    }

    function aggiornaPrezzo() {
        // Trova l'allestimento selezionato, se non c'è nessuno, richiama la funzione
        const sel = document.querySelector('input[name="idAllestimento"]:checked');

        // Se non c'è selezione e ci sono radio disponibili, seleziona la prima
        if (!sel && radios.length > 0) {
            radios[0].checked = true;
            return aggiornaPrezzo(); // Richiama la funzione dopo aver selezionato
        }

        // Ottiene il prezzo dell'allestimento selezionato con parsing più sicuro
        let prezzoAll = 0;
        if (sel && sel.dataset.prezzo) {
            let prezzoAllStr = sel.dataset.prezzo.toString();
            console.log("Prezzo allestimento originale:", prezzoAllStr);

            // Rimuove simboli e spazi
            prezzoAllStr = prezzoAllStr.replace(/€/g, '').replace(/\u00A0/g, '').replace(/\s/g, '').trim();
            console.log("Prezzo allestimento pulito:", prezzoAllStr);

            // Stessa logica del prezzo base
            if (prezzoAllStr.match(/^\d+$/)) {
                prezzoAll = parseInt(prezzoAllStr) || 0;
            } else if (prezzoAllStr.match(/^\d+\.\d{1,2}$/)) {
                prezzoAll = parseFloat(prezzoAllStr) || 0;
            } else if (prezzoAllStr.match(/^\d{1,3}(\.\d{3})+$/)) {
                prezzoAllStr = prezzoAllStr.replace(/\./g, '');
                prezzoAll = parseInt(prezzoAllStr) || 0;
            } else if (prezzoAllStr.match(/^\d{1,3}(\.\d{3})+,\d{1,2}$/)) {
                prezzoAllStr = prezzoAllStr.replace(/\./g, '').replace(',', '.');
                prezzoAll = parseFloat(prezzoAllStr) || 0;
            } else {
                // Fallback: rimuove tutto tranne numeri e punto/virgola
                prezzoAllStr = prezzoAllStr.replace(/[^\d.,]/g, '');
                if (prezzoAllStr.includes(',')) {
                    prezzoAllStr = prezzoAllStr.replace(',', '.');
                }
                prezzoAll = parseFloat(prezzoAllStr) || 0;
            }

            console.log("Prezzo allestimento finale:", prezzoAll);
        }

        const totale = basePrezzo + prezzoAll;

        console.log("Calcolo prezzo:", {
            base: basePrezzo,
            allestimento: prezzoAll,
            totale: totale,
            allestimentoSelezionato: sel ? sel.value : 'nessuno'
        });

        // Aggiorna il display del prezzo totale
        if (prezzoDisplay) {
            prezzoDisplay.textContent = '€' + totale.toLocaleString('it-IT', {
                minimumFractionDigits: 2,
                maximumFractionDigits: 2
            });
        }

        // Sincronizzo hidden se presente
        if (hiddenAllElem) {
            hiddenAllElem.value = sel ? sel.value : '';
        }

        //restituisce un oggetto js con tutti i valori, utile se altre funzioni vogliono leggerli
        return {
            totale: totale,
            idAllestimento: sel ? sel.value : null,
            prezzoBase: basePrezzo,
            prezzoAllestimento: prezzoAll
        };
    }

    // Inizializzazione: se ci sono allestimenti, seleziona il primo se nessuno è selezionato
    if (radios.length > 0) {
        let hasChecked = false;
        radios.forEach(r => {
            if (r.checked) hasChecked = true;
        });

        // Se nessuno è selezionato, seleziona il primo
        if (!hasChecked) {
            radios[0].checked = true;
        }
    }

    // Prima inizializzazione del prezzo per mostrare il prezzo totale corretto appena carica la pagina
    aggiornaPrezzo();

    //Quando l'utente seleziona un allestimento, il prezzo totale si aggiorna al volo senza ricaricare la pagina
    if (radios && radios.length) {
        radios.forEach(r => {
            r.addEventListener('change', function() {
                console.log("Allestimento cambiato a:", this.value, "prezzo:", this.dataset.prezzo);
                aggiornaPrezzo();
            });
        });
    }

    // Esponi la funzione aggiornaPrezzo globalmente per uso esterno
    window.aggiornaPrezzo = aggiornaPrezzo;
});