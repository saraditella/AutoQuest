document.addEventListener("DOMContentLoaded", function () {
    console.log("Inizializzazione sistema filtri...");

    const filtroForm = document.getElementById("filtroForm");
    const risultatiContainer = document.getElementById("catalogoRisultati");

    if (!filtroForm) {
        console.error("Form filtri non trovato!");
        return;
    }

    if (!risultatiContainer) {
        console.error("Container risultati non trovato!");
        return;
    }

    // Seleziona tutti gli input del form
    const inputs = filtroForm.querySelectorAll("select, input[type=checkbox]");
    console.log("Trovati", inputs.length, "elementi di filtro");

    // Aggiunge event listener a tutti gli input
    inputs.forEach((input, index) => {
        console.log(`Attacco listener a input ${index}:`, input.name, input.type);
        input.addEventListener("change", function() {
            console.log("Cambio rilevato su:", this.name, "valore:", this.value, "checked:", this.checked);
            filtraAuto(1); // Reset a pagina 1 quando cambiano i filtri
        });
    });

    // Funzione principale per filtrare le auto
    function filtraAuto(pagina = 1) {
        console.log("=== INIZIO FILTRO AUTO - Pagina:", pagina, "===");

        const formData = new FormData(filtroForm);
        const params = new URLSearchParams();

        // Debug: mostra tutti i dati del form
        console.log("Dati form raw:");
        for (let [key, value] of formData.entries()) {
            console.log(`  ${key}: "${value}"`);
        }

        // Processa i dati del form
        for (let [key, value] of formData.entries()) {
            if (value && value.trim() !== '') {
                params.append(key, value); // Usa append per supportare checkbox multipli
            }
        }

        // Aggiunge il numero di pagina
        params.set("pagina", pagina.toString());

        // Costruisce l'URL
        const url = contextPath + "/filtra-dinamicamente-servlet?" + params.toString();
        console.log("URL chiamata AJAX:", url);

        // Mostra loading se necessario
        risultatiContainer.innerHTML = '<div class="text-center p-4"><div class="spinner-border" role="status"><span class="sr-only">Caricamento...</span></div></div>';

        // Chiamata AJAX
        fetch(url, {
            method: 'GET',
            headers: {
                'X-Requested-With': 'XMLHttpRequest'
            }
        })
            .then(response => {
                console.log("Risposta ricevuta - Status:", response.status, "OK:", response.ok);
                if (!response.ok) {
                    throw new Error(`Errore HTTP: ${response.status} ${response.statusText}`);
                }
                return response.text();
            })
            .then(html => {
                console.log("HTML ricevuto - Lunghezza:", html.length);
                console.log("Prime 200 caratteri:", html.substring(0, 200));

                // Aggiorna il contenuto
                risultatiContainer.innerHTML = html;

                // Riattiva tutti i listener necessari
                attachPaginationListeners();
                reattachOtherListeners();

                console.log("=== FILTRO COMPLETATO ===");
            })
            .catch(error => {
                console.error("ERRORE nella chiamata AJAX:", error);
                risultatiContainer.innerHTML = `
                <div class="alert alert-danger p-4">
                    <h4>Errore nel caricamento</h4>
                    <p>Si è verificato un errore: ${error.message}</p>
                    <button onclick="location.reload()" class="btn btn-primary">Ricarica la pagina</button>
                </div>
            `;
            });
    }

    // Gestione della paginazione
    function attachPaginationListeners() {
        const paginationLinks = document.querySelectorAll(".pagination-link");
        console.log("Attacco listener paginazione a", paginationLinks.length, "link");

        paginationLinks.forEach((link, index) => {
            // Rimuovi listener precedenti per evitare duplicati
            const newLink = link.cloneNode(true);
            link.parentNode.replaceChild(newLink, link);

            // Aggiungi nuovo listener
            newLink.addEventListener("click", function(e) {
                e.preventDefault();
                const pagina = this.dataset.page;
                console.log(`Click su link paginazione ${index}, pagina:`, pagina);

                if (pagina && !isNaN(pagina)) {
                    filtraAuto(parseInt(pagina));
                } else {
                    console.error("Pagina non valida:", pagina);
                }
            });
        });
    }

    // Riattiva altri listener dopo AJAX
    function reattachOtherListeners() {
        console.log("Riattivazione altri listener...");

        // Listener per form confronto
        const confrontoForms = document.querySelectorAll('.confronto-form');
        console.log("Trovati", confrontoForms.length, "form confronto");

        confrontoForms.forEach(form => {
            if (!form.hasAttribute('data-listener-ready')) {
                form.setAttribute('data-listener-ready', 'true');
                form.addEventListener('submit', handleConfrontoSubmit);
            }
        });

        // Altri listener possono essere aggiunti qui
    }

    // Handler per form confronto
    function handleConfrontoSubmit(e) {
        e.preventDefault();
        console.log("Submit form confronto");

        const form = e.target;
        const formData = new FormData(form);

        fetch(form.action, {
            method: 'POST',
            body: formData
        })
            .then(response => response.json())
            .then(data => {
                console.log("Risposta confronto:", data);
                if (data.success) {
                    // Aggiorna contatore se presente
                    const counter = document.querySelector('.confronto-counter');
                    if (counter && data.count !== undefined) {
                        counter.textContent = data.count;
                    }

                    // Feedback visuale
                    const button = form.querySelector('button');
                    if (button) {
                        const originalText = button.innerHTML;
                        button.innerHTML = '✓ Aggiunto';
                        button.classList.add('btn-success');
                        button.disabled = true;

                        setTimeout(() => {
                            button.innerHTML = originalText;
                            button.classList.remove('btn-success');
                            button.disabled = false;
                        }, 2000);
                    }
                }
            })
            .catch(error => {
                console.error('Errore confronto:', error);
            });
    }

    // Inizializzazione al caricamento della pagina
    console.log("Inizializzazione listener iniziali...");
    attachPaginationListeners();
    reattachOtherListeners();

    console.log("Sistema filtri completamente inizializzato!");
});