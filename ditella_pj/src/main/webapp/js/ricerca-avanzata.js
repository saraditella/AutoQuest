document.addEventListener("DOMContentLoaded", function () {
    const ricercaForm = document.getElementById("ricercaAvanzataForm");
    const inputs = ricercaForm.querySelectorAll("select");
    const risultatiContainer = document.getElementById("risultatiRicercaAvanzata");

    // Aggiunge event listener ai filtri (reset pagina a 1)
    inputs.forEach(input => {
        input.addEventListener("change", () => filtraAutoAvanzata(1));
    });

    // Funzione per inviare filtri + pagina al servlet
    function filtraAutoAvanzata(pagina = 1) {
        const formData = new FormData(ricercaForm);
        const params = new URLSearchParams();

        // Inserisce i filtri
        for (let [key, value] of formData.entries()) {
            if (value && value.trim() !== "") {
                params.set(key, value);
            }
        }

        // Aggiunge parametro pagina
        params.set("pagina", pagina);

        // Chiamata fetch
        fetch("ricerca-avanzata-servlet?" + params.toString())
            .then(response => response.text())
            .then(html => {
                if (risultatiContainer) {
                    // Estrae solo la parte dei risultati dalla risposta
                    const parser = new DOMParser();
                    const doc = parser.parseFromString(html, 'text/html');
                    const nuoviRisultati = doc.getElementById('risultatiRicercaAvanzata');

                    if (nuoviRisultati) {
                        risultatiContainer.innerHTML = nuoviRisultati.innerHTML;
                    }

                    // Riattiva link paginazione dopo ogni fetch
                    attachPaginationListeners();
                }
            })
            .catch(error => console.error("Errore nel filtro avanzato:", error));
    }

    // Listener per i link di paginazione
    function attachPaginationListeners() {
        const paginationLinks = document.querySelectorAll(".pagination-link");
        paginationLinks.forEach(link => {
            link.addEventListener("click", function (e) {
                e.preventDefault();
                const pagina = this.dataset.page;
                filtraAutoAvanzata(pagina);
            });
        });
    }

    // Inizializza i listener per la paginazione al caricamento
    attachPaginationListeners();
});