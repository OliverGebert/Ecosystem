<template>
  <div>
    <p>API Meldung: {{ apiMessage }}</p>
    <button @click="fetchMessage">Aktualisieren</button>
  </div>
</template>

<script>
import { ref } from "vue";

export default {
  name: "HelloAPI",
  setup() {
    const apiMessage = ref("...lädt");

    const fetchMessage = async () => {
      try {
        const res = await fetch("http://localhost:8040/message");
        const data = await res.json();
        apiMessage.value = data.message;
      } catch (err) {
        apiMessage.value = "Fehler beim Abrufen der API";
        console.error(err);
      }
    };

    fetchMessage(); // direkt beim Laden

    return { apiMessage, fetchMessage };
  },
};
</script>

