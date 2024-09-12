// webapp/js/acquista.js - Sistema acquisto completo
//la prima istruzione serve a dire che tutto il codice viene eseguito solo quando la pagina è stata caricata completamente (HTML pronto)
document.addEventListener("DOMContentLoaded", function () {
    const ctx = (typeof contextPath !== 'undefined') ? contextPath : (window.contextPath || ''); //si prende la variabile contextPath per costruire url richieste, se non c'è usa windows

    function mostraMsg(text) {
        //se esiste la funzione globale definita si mostra messaggio stilizzato di successo o errore altrimenti si ripiega su un alert()
        if (typeof window.mostraMessaggio === "function") {
            window.mostraMessaggio(text, "success");
        } else {
            alert(text);
        }
    }

    function mostraErr(text) {
        if (typeof window.mostraMessaggio === "function") {
            window.mostraMessaggio(text, "error");
        } else {
            alert(text);
        }
    }

    // registra ordine e apre link esterno (se fornito).
    function registraOrdineEApriLink(idAuto, idAllestimento, linkAcquisto) {
        const formData = new URLSearchParams();
        //prepara i dati da inviare al server(POST form-encoded)
        formData.append('idAuto', idAuto || '');
        formData.append('idAllestimento', idAllestimento || '');
        formData.append('externalUrl', linkAcquisto || '');
        //manda la richiesta alla servlet acquista
        //se la servlet risponde con { success:true, message:..., externalUrl:... } mostra il messaggio, apre il link esterno e aggiorna lapag altrimenti se success:false mostra errore
        fetch(ctx + '/acquista', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8'
            },
            credentials: 'same-origin',
            body: formData
        })
            .then(r => {
                if (!r.ok) throw new Error('HTTP ' + r.status);
                return r.json();
            })
            .then(data => {
                if (data.success) {
                    mostraMsg(data.message || 'Ordine registrato con successo');
                    // apri link (usiamo externalUrl dalla risposta se presente, altrimenti il link passato)
                    const url = (data.externalUrl && data.externalUrl.trim() !== '') ? data.externalUrl : (linkAcquisto || '');
                    if (url && url.trim() !== '') {
                        window.open(url, '_blank'); //apre il sito esterno del venditore
                    }
                    // ricarica per aggiornare lo storico ordini (small delay per esperienza utente)
                    setTimeout(() => window.location.reload(), 600);
                } else {
                    mostraErr(data.message || 'Errore durante la registrazione ordine');
                }
            })
            .catch(err => {
                console.error('acquista error', err);
                mostraErr('Errore di connessione durante la registrazione dell\'ordine');
            });
    }

    // Funzione principale per l'acquisto dal garage - CON POPUP CONFERMA
    window.acquistaERegistra = function(idAuto, idAllestimento, linkAcquisto) {
        if (!idAuto) {
            mostraErr('ID auto mancante');
            return;
        }

        if (!confirm('Sei sicuro di voler procedere con l\'acquisto?')) {
            return;
        }
        // Se l'utente è loggato (verifica nel DOM), registra ordine + apri link
        if (document.querySelector('[data-user-logged="true"]')) {
            registraOrdineEApriLink(idAuto, idAllestimento, linkAcquisto);
        } else {
            // Se non è loggato, apri solo il link
            if (linkAcquisto && linkAcquisto.trim() !== '') {
                window.open(linkAcquisto, '_blank');
            } else {
                mostraErr('Link di acquisto non disponibile');
            }
        }
    };

    // funzione globale da usare nel catalogo (gestisce login/non-login)
    window.acquistaDelCatalogo = function(idAuto, idAllestimento, linkAcquisto, marchio, modello) {
        if (!confirm(`Procedere all'acquisto di ${marchio} ${modello}?`)) return;

        if (document.querySelector('[data-user-logged="true"]')) {
            registraOrdineEApriLink(idAuto, idAllestimento, linkAcquisto);
        } else {
            if (linkAcquisto && linkAcquisto.trim() !== '') {
                window.open(linkAcquisto, '_blank');
            } else {
                mostraErr('Link di acquisto non disponibile');
            }
        }
    };

    // Acquisto diretto senza registrazione ordine
    window.acquistaDiretto = function(linkAcquisto) {
        if (linkAcquisto && linkAcquisto.trim() !== '') {
            window.open(linkAcquisto, '_blank');
        } else {
            mostraErr('Link di acquisto non disponibile');
        }
    };

    // salva in garage (AJAX). Richiede login (controlla data-user-logged nel DOM)
    window.salvaInGarage = function(idAuto, idAllestimento) {
        if (!document.querySelector('[data-user-logged="true"]')) {
            if (confirm('Devi effettuare il login per salvare nel garage. Vuoi accedere ora?')) {
                window.location.href = ctx + '/login';
            }
            return;
        }

        const formData = new URLSearchParams();
        formData.append('idAuto', idAuto || '');
        formData.append('idAllestimento', idAllestimento || '');

        fetch(ctx + '/salva-garage', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded;charset=UTF-8'
            },
            credentials: 'same-origin',
            body: formData
        })
            .then(r => {
                if (!r.ok) throw new Error('HTTP ' + r.status);
                return r.json();
            })
            .then(data => {
                if (data.success) {
                    mostraMsg(data.message || 'Auto salvata nel garage');
                } else {
                    mostraErr(data.message || 'Errore nel salvataggio');
                }
            })
            .catch(err => {
                console.error('salvaInGarage err', err);
                mostraErr('Errore di connessione durante il salvataggio');
            });
    };
});