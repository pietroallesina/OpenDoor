document.addEventListener('DOMContentLoaded', function() {
    const calendarEl = document.getElementById('calendar'); 
    const calendar = new FullCalendar.Calendar(calendarEl, {
        locale: 'it',   // language
        firstDay: 1,    // Monday
        initialView: 'timeGridWeek',
        headerToolbar: { left:'prev,next today', center:'title', right:'timeGridWeek,dayGridMonth'},
        buttonText: { today:'oggi', month:'mese', week:'settimana'},

        slotMinTime: "07:00:00", // starting time
        nowIndicator: true,

        events: '/api/calendar.php',

        eventClick: function(info) {
            // Aggiungi informazioni sull'evento alla URL
            const url = new URL('/datemenu', window.location.origin);
            url.searchParams.append('id', info.event.extendedProps.id);
            window.open(url.toString(), 'Nuova prenotazione', 'width=1000,height=500');
        },
    });

    calendar.render();
});