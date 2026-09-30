<script setup>
import { onMounted, ref } from 'vue'

const products = ref([])
const loading = ref(true)
const error = ref('')

const icons = {
  'Health Plan': '♡',
  'Car Insurance': '🚗',
  'Pet Health': '🐾',
  'Home Protection Plan': '⌂',
}

async function loadProducts() {
  loading.value = true
  error.value = ''

  try {
    const response = await fetch('/api/products', {
      headers: { Accept: 'application/json' },
    })

    if (!response.ok) {
      throw new Error(`Request failed: ${response.status}`)
    }

    const result = await response.json()

    if (!Array.isArray(result.data)) {
      throw new Error('Unexpected product response')
    }

    products.value = result.data
  } catch (err) {
    console.error('Could not load products:', err)
    error.value = 'We could not load the insurance plans. Please try again.'
  } finally {
    loading.value = false
  }
}

onMounted(loadProducts)
</script>

<template>
    <div class="site">
  <header class="site-header">
    <div class="wrap brand">
      <span class="brand-mark" aria-hidden="true">
        <svg
          viewBox="0 0 24 24"
          fill="none"
          stroke="currentColor"
          stroke-width="1.7"
          stroke-linecap="round"
          stroke-linejoin="round"
        >
          <path d="M12 3 20 6v6c0 5-8 9-8 9s-8-4-8-9V6Z" />
          <path d="m8 12 3 3 5-6" />
        </svg>
      </span>
      <span>nuinsurance</span>
    </div>
  </header>


  <main class="wrap">
    <section class="intro" aria-labelledby="intro-title">
      <h1 id="intro-title">nuinsurance</h1>

      <p>
        Insurance starts with understanding what matters to you. At
        nuinsurance, we bring health, car, pet and home insurance options
        into one place, making it easier to explore the cover you need.
      </p>

      <p>
        Whether you are thinking about your health, your next journey or
        the place you call home, start with the plans below. Take your
        time, explore your options and find a starting point that suits you.
      </p>
    </section>

    <section class="products" aria-labelledby="plans-title">
      <h2 id="plans-title">Explore our insurance plans</h2>

      <p v-if="loading" class="status" role="status">
        Loading insurance plans…
      </p>

      <div v-else-if="error" class="status error" role="alert">
        <p>{{ error }}</p>
        <button type="button" @click="loadProducts">Try again</button>
      </div>

      <p v-else-if="products.length === 0" class="status">
        No insurance plans are available yet. Please check back later.
      </p>

      <div v-else class="product-grid">
        <article
          v-for="product in products"
          :key="product.id"
          class="product-card"
        >
          <div class="product-icon" aria-hidden="true">
            {{ icons[product.name] || '◇' }}
          </div>

          <h3>{{ product.name }}</h3>
          <p>{{ product.description }}</p>
        </article>
      </div>
    </section>
  </main>
  </div>
</template>