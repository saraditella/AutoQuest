// webapp/js/confronto-dinamico.js
document.addEventListener("DOMContentLoaded", function () {
    // contextPath support (JSP dovrebbe definire contextPath globalmente)
    const ctx = (typeof contextPath !== 'undefined') ? contextPath : (window.contextPath || '');

    // Funzione per aggiornare il badge nell'header e i contatori in pagina
    function aggiornaBadgeConfronto(count) {
        // Badge header
        const badgeHeader = document.querySelector('.numero-confrontati-nav');
        const link = document.querySelector('.confronto-link');

        if (count > 0) {
            if (badgeHeader) {
                badgeHeader.textContent = count;
            } else if (link) {
                const newBadge = document.createElement('span');
                newBadge.classList.add('numero-confrontati-nav');
                newBadge.textContent = count;
                link.appendChild(newBadge);
            }
        } else {
            if (badgeHeader) badgeHeader.remove();
        }

        // Aggiorna sempre i contatori in pagina (anche quando è 0)
        document.querySelectorAll(".confronto-numero")
            .forEach(el => el.textContent = count);
    }

    //mostrare notifiche temporanee
    window.mostraMessaggio = function (text, tipo) {
        // rimuovo eventuali messaggi vecchi
        document.querySelectorAll(".messaggio-temporaneo").forEach(m => m.remove());
        //creazione di elemento div che contiene il messaggio
        const div = document.createElement("div");
        div.className = `messaggio-temporaneo messaggio-${tipo}`;
        div.style.cssText = `
            position: fixed;
            top: 20px; right: 20px;
            padding: 15px 20px;
            border-radius: 5px;
            color: white;
            font-weight: bold;
            z-index: 1000;
            background-color: ${tipo === "success" ? "#28a745" : "#dc3545"};
            box-shadow: 0 2px 10px rgba(0,0,0,0.2);
            max-width: 320px;
            word-wrap: break-word;
        `;

        //inserisce il messaggio nel div e llo aggiunge al dom affinche sia visibile
        div.textContent = text;
        document.body.appendChild(div);
        setTimeout(() => {
            div.style.opacity = "0";
            div.style.transition = "opacity 0.5s";
            setTimeout(() => div.remove(), 500);
        }, 4000);
    };

    // Controlla se siamo su una pagina di confronto salvato
    function isConfrontoSalvato() {
        // Verifica se c'è l'indicatore di confronto salvato nella pagina
        const confrontoSalvatoIndicator = document.querySelector('[data-confronto-salvato="true"]');
        return confrontoSalvatoIndicator !== null;
    }

    // Conta le auto visibili nella tabella di confronto
    function contaAutoInTabella() {
        const tableRows = document.querySelectorAll('.confronto-table .table-row-images td.table-cell-image');
        return tableRows.length;
    }

    // 1) Aggiorna il contatore quando la pagina è carica
    if (isConfrontoSalvato()) {
        // Se è un confronto salvato, conta le auto dalla tabella
        const count = contaAutoInTabella();
        aggiornaBadgeConfronto(count);
    } else {
        // Se è il confronto normale, usa la servlet per ottenere il count dalla sessione
        aggiornaContatoreConfronto();
    }

    // 2) Listener specifico per il form del confronto nella pagina dettaglio
    const formConfronto = document.getElementById('formAddConfronto');
    if (formConfronto) {
        formConfronto.addEventListener('submit', function(e) {
            e.preventDefault(); // Impedisce il submit normale del form

            console.log('Form confronto submitted'); // Debug

            // Aggiorna il campo hidden con l'allestimento selezionato
            const selectedRadio = document.querySelector('input[name="idAllestimento"]:checked');
            const hiddenAllestimento = document.getElementById('hiddenIdAllestimento');

            if (selectedRadio && hiddenAllestimento) {
                hiddenAllestimento.value = selectedRadio.value;
                console.log('Allestimento selezionato:', selectedRadio.value); // Debug
            }

            // Ottieni i dati dal form
            const formData = new FormData(formConfronto);
            const params = new URLSearchParams();

            // Converti FormData in URLSearchParams
            for (let [key, value] of formData.entries()) {
                params.append(key, value);
            }

            console.log('Parametri da inviare:', params.toString()); // Debug

            // Invia la richiesta AJAX
            fetch((ctx || '') + "/aggiungi-confronto-servlet", {
                method: "POST",
                headers: {
                    "Content-Type": "application/x-www-form-urlencoded;charset=UTF-8"
                },
                body: params.toString(),
                credentials: 'same-origin'
            })
                .then(response => {
                    console.log('Response status:', response.status); // Debug
                    if (!response.ok) {
                        throw new Error(`HTTP ${response.status} – ${response.statusText}`);
                    }
                    const ct = response.headers.get("content-type") || "";
                    if (!ct.includes("application/json")) {
                        throw new Error("Risposta non JSON dal server");
                    }
                    return response.json();
                })
                .then(data => {
                    console.log('Response data:', data); // Debug
                    window.mostraMessaggio(data.message, data.success ? "success" : "error");
                    if (typeof data.count !== "undefined") {
                        aggiornaBadgeConfronto(data.count);
                    }
                })
                .catch(err => {
                    console.error('Errore:', err); // Debug
                    window.mostraMessaggio("Errore durante l'aggiunta al confronto: " + err.message, "error");
                });
        });
    }

    // 3) Listener generico per altri pulsanti "Aggiungi al confronto" (per altre pagine)
    document.addEventListener("click", function (e) {
        // Controllo per pulsanti con classe btn-aggiungi-confronto
        if (!e.target.classList.contains("btn-aggiungi-confronto")) {
            return;
        }

        e.preventDefault();
        console.log('Pulsante confronto generico cliccato'); // Debug

        const btn = e.target;
        const form = btn.closest("form");
        if (!form) {
            window.mostraMessaggio("Errore interno: form non trovato", "error");
            return;
        }

        const idAutoInput = form.querySelector('input[name="idAuto"]');
        const idAuto = idAutoInput ? idAutoInput.value.trim() : null;

        if (!idAuto) {
            window.mostraMessaggio("Errore: ID auto non valido", "error");
            return;
        }

        const params = new URLSearchParams();
        params.append("idAuto", idAuto);
        params.append("ajax", "true");

        let idAll = '';
        const hiddenInput = form.querySelector('input[name="idAllestimento"][type="hidden"]');
        if (hiddenInput && hiddenInput.value) {
            idAll = hiddenInput.value;
        } else {
            const radioChecked = form.querySelector('input[name="idAllestimento"]:checked');
            if (radioChecked) idAll = radioChecked.value;
        }
        if (idAll) params.append("idAllestimento", idAll);

        // Invio richiesta AJAX
        fetch((ctx || '') + "/aggiungi-confronto-servlet", {
            method: "POST",
            headers: {
                "Content-Type": "application/x-www-form-urlencoded;charset=UTF-8"
            },
            body: params.toString(),
            credentials: 'same-origin'
        })
            .then(response => {
                if (!response.ok) {
                    throw new Error(`HTTP ${response.status} – ${response.statusText}`);
                }
                const ct = response.headers.get("content-type") || "";
                if (!ct.includes("application/json")) {
                    throw new Error("Risposta non JSON dal server");
                }
                return response.json();
            })
            .then(data => {
                window.mostraMessaggio(data.message, data.success ? "success" : "error");
                if (typeof data.count !== "undefined") {
                    aggiornaBadgeConfronto(data.count);
                }
            })
            .catch(err => {
                window.mostraMessaggio("Errore durante l'aggiunta al confronto: " + err.message, "error");
            });
    });

    // Funzione per aggiornare il counter
    function aggiornaContatoreConfronto(count) {
        if (typeof count === "undefined") {
            fetch((ctx || '') + "/confronto-info", { credentials: 'same-origin' })
                .then(r => {
                    if (!r.ok) throw new Error('no');
                    return r.json();
                })
                .then(d => aggiornaBadgeConfronto(d.count))
                .catch(() => {});
        } else {
            aggiornaBadgeConfronto(count);
        }
    }

    // Espongo la funzione per eventuale uso esterno
    window.aggiornaContatoreConfronto = aggiornaContatoreConfronto;
});