<script setup></script>

<template>
  <h1>You did it!</h1>
  <p>
    Visit <a href="https://vuejs.org/" target="_blank" rel="noopener">vuejs.org</a> to read the
    documentation
    <EcoAPI />
  </p>
</template>

<script>
import EcoAPI from "./components/EcoAPI.vue";

export default {
  name: "App",
  components: { EcoAPI },
};
</script>

<style scoped></style>
