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

        events: async function(fetchInfo, successCallback, failureCallback) {
            try {
                const response = await fetch('/api/calendar.php');

                if (!response.ok) {
                    throw new Error('Network response was not ok');
                }

                const data = await response.json();

                // Map API events to FullCalendar event format
                const events = data.map(event => ({
                    title: event.summary,
                    start: event.start,
                    // url: event.htmlLink,
                    allDay: !event.start.includes('T')  // crude check for all-day events
                }));

                successCallback(events);

            } catch (error) {
                failureCallback(error);
            }
        },

        eventClick: function(info) {
            info.jsEvent.preventDefault(); // prevent default browser navigation
            if (info.event.url) {
                window.open(info.event.url, '_blank');
            }
        },
    });

    calendar.render();
});