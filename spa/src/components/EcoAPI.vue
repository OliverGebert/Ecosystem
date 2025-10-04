<template>
  <div class="p-4">
    <h2>Ecosystems</h2>

    <button @click="loadEcosystems" class="btn">Load Ecosystems</button>

    <ul v-if="ecosystems.length > 0">
      <li
        v-for="eco in ecosystems"
        :key="eco.id"
        @click="loadEcosystem(eco.id)"
        class="cursor-pointer hover:underline"
      >
        {{ eco.name }}
      </li>
    </ul>

    <div v-else class="text-gray-500 mt-2">No ecosystems loaded yet.</div>

    <div v-if="selectedEcosystem" class="mt-4 p-2 border rounded">
      <h3>Selected Ecosystem:</h3>
      <p><strong>ID:</strong> {{ selectedEcosystem.id }}</p>
      <p><strong>Name:</strong> {{ selectedEcosystem.name }}</p>
      <p><strong>Description:</strong> {{ selectedEcosystem.description }}</p>
    </div>
  </div>
</template>

<script setup>
import { ref } from "vue";

const apiBase = "http://localhost:8040";

const ecosystems = ref([]);
const selectedEcosystem = ref(null);

const loadEcosystems = async () => {
  try {
    const res = await fetch(`${apiBase}/ecosystems`);
    if (!res.ok) throw new Error(`HTTP error! status: ${res.status}`);
    ecosystems.value = await res.json();
  } catch (err) {
    console.error("Error loading ecosystems:", err);
  }
};

const loadEcosystem = async (id) => {
  try {
    const res = await fetch(`${apiBase}/ecosystems/${id}`);
    if (!res.ok) throw new Error(`HTTP error! status: ${res.status}`);
    selectedEcosystem.value = await res.json();
  } catch (err) {
    console.error("Error loading ecosystem:", err);
  }
};
</script>

<style scoped>
.btn {
  background-color: #42b983;
  color: white;
  padding: 0.5rem 1rem;
  border-radius: 4px;
  margin-bottom: 1rem;
}
</style>

