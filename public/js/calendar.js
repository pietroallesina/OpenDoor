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
            info.jsEvent.preventDefault(); // prevent default browser navigation
            if (info.event.url) {
                window.open(info.event.url, '_blank');
            }
        },
    });

    calendar.render();
});