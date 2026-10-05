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
  <main class="mx-auto max-w-[1244px] px-5 pb-20 sm:px-8">
    <section
      class="max-w-[800px] pt-12 pb-10 sm:pt-18 sm:pb-12"
      aria-labelledby="intro-title"
    >
      <h1
        id="intro-title"
        class="mb-6 text-5xl font-extrabold tracking-tight sm:text-7xl"
      >
        nuinsurance
      </h1>

      <div class="max-w-[730px] space-y-5 text-base leading-8 text-[#52627b] sm:text-lg">
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
      </div>
    </section>

    <section aria-labelledby="plans-title">
      <h2 id="plans-title" class="mb-6 text-2xl font-bold tracking-tight">
        Explore our insurance plans
      </h2>

      <p
        v-if="loading"
        class="rounded-xl border border-[#dce5ef] bg-white p-6"
        role="status"
      >
        Loading insurance plans…
      </p>

      <div
        v-else-if="error"
        class="rounded-xl border border-red-200 bg-white p-6"
        role="alert"
      >
        <p class="text-red-700">{{ error }}</p>
        <button
          type="button"
          class="mt-4 cursor-pointer rounded-lg bg-[#15233b] px-5 py-3 font-semibold text-white hover:bg-slate-700 focus-visible:outline-2 focus-visible:outline-offset-4 focus-visible:outline-blue-600"
          @click="loadProducts"
        >
          Try again
        </button>
      </div>

      <p
        v-else-if="products.length === 0"
        class="rounded-xl border border-[#dce5ef] bg-white p-6"
      >
        No insurance plans are available yet. Please check back later.
      </p>

      <div v-else class="grid grid-cols-1 gap-5 sm:grid-cols-2 lg:grid-cols-4">
        <article
          v-for="product in products"
          :key="product.id"
          class="flex flex-col rounded-2xl border border-[#dce5ef] bg-white p-6"
        >
          <div
            class="mb-7 grid h-13 w-13 place-items-center rounded-xl bg-[#e7eafe] text-3xl text-[#2f49e0]"
            aria-hidden="true"
          >
            {{ icons[product.name] || '◇' }}
          </div>

          <h3 class="mb-3 text-xl leading-tight font-bold tracking-tight">
            {{ product.name }}
          </h3>

          <p class="mb-6 text-[15px] leading-7 text-[#52627b]">
            {{ product.description }}
          </p>

          <RouterLink
            :to="{ name: 'product-details', params: { id: product.id } }"
            class="mt-auto self-start rounded font-semibold text-[#2f49e0] hover:underline focus-visible:outline-2 focus-visible:outline-offset-4 focus-visible:outline-blue-600"
          >
            View details →
          </RouterLink>
        </article>
      </div>
    </section>
  </main>
</template>