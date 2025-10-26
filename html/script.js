const { createApp } = Vue;

createApp({
    data() {
        return {
            teritorijaInfo: {
                ime: "",
                vlasnik: null,
                zauzetaOd: null,
                novacPoSatu: 0
            },
            progress: 0,
            preostaloVrijeme: 0,
            showInfo: false,
            showProgress: false
        }
    },
    mounted() {
        window.addEventListener('message', (event) => {
            const data = event.data;
            
            if (data.action === 'showInfo') {
                this.teritorijaInfo = {
                    ime: data.config.ime,
                    vlasnik: data.teritorija.vlasnik,
                    zauzetaOd: data.teritorija.zauzetaOd,
                    novacPoSatu: data.config.novacPoSatu
                };
                this.showInfo = true;
            }
            else if (data.action === 'hideInfo') {
                this.showInfo = false;
            }
            else if (data.action === 'showProgress') {
                this.showProgress = true;
            }
            else if (data.action === 'hideProgress') {
                this.showProgress = false;
            }
            else if (data.action === 'progress') {
                this.progress = data.progress;
            }
            else if (data.action === 'updateTime') {
                this.preostaloVrijeme = data.time;
            }
        });
    },
    methods: {
        zatvoriInfo() {
            this.showInfo = false;
            fetch('https://territory-system/zatvori', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({})
            });
        },
        formatirajVrijeme(timestamp) {
            if (!timestamp) return 'Nepoznato';
        
            const date = new Date(timestamp * 1000);
        
            const day = String(date.getDate()).padStart(2, '0');     
            const month = String(date.getMonth() + 1).padStart(2, '0'); 
            const year = date.getFullYear();
        
            const hours = String(date.getHours()).padStart(2, '0');
            const minutes = String(date.getMinutes()).padStart(2, '0');
        
            return `${day}/${month}/${year}, ${hours}:${minutes}`;
        }         
    }
}).mount('#app');
