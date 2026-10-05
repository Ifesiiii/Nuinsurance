<script setup>
import { ref, watch } from 'vue'
import { useRoute } from 'vue-router'
import QuoteRequestForm from '../components/QuoteRequestForm.vue'



const route = useRoute()

const product = ref(null)
const loading = ref(true)
const error = ref('')
const notFound = ref(false)
const retryCount = ref(0)

const detailSections = [
  { key: 'coverage', title: "What's covered" },
  { key: 'exclusions', title: "What's not covered" },
  { key: 'eligibility', title: "Who it's for" },
  { key: 'conditions', title: 'Limits and conditions' },
]

function hasDetails(value) {
  return typeof value === 'string' && value.trim().length > 0
}

const showQuoteForm = ref(false)

watch(
  [() => route.params.id, retryCount],
  async ([id], _previous, onCleanup) => {
    const controller = new AbortController()
    onCleanup(() => controller.abort())

    loading.value = true
    error.value = ''
    notFound.value = false
    product.value = null

    try {
      const response = await fetch(
        `/api/products/${encodeURIComponent(id)}`,
        {
          headers: { Accept: 'application/json' },
          signal: controller.signal,
        },
      )

      if (response.status === 404) {
        notFound.value = true
        return
      }

      if (!response.ok) {
        throw new Error(`Request failed: ${response.status}`)
      }

      const result = await response.json()

      if (!result.data || typeof result.data.name !== 'string') {
        throw new Error('Unexpected product response')
      }

      product.value = result.data
    } catch (err) {
      if (controller.signal.aborted) return

      console.error('Could not load product:', err)
      error.value = 'We could not load this plan. Please try again.'
    } finally {
      if (!controller.signal.aborted) {
        loading.value = false
      }
    }
  },
  { immediate: true },
)
</script>

<template>
  <main class="mx-auto max-w-311 px-5 pt-10 pb-20 sm:px-8">
    <RouterLink
      to="/products"
      class="mb-8 inline-block rounded font-semibold text-[#2f49e0] hover:underline focus-visible:outline-2 focus-visible:outline-offset-4 focus-visible:outline-blue-600"
    >
      ← Back to plans
    </RouterLink>

    <p
      v-if="loading"
      class="rounded-xl border border-[#dce5ef] bg-white p-6"
      role="status"
    >
      Loading product details…
    </p>

    <section
      v-else-if="notFound"
      class="rounded-xl border border-[#dce5ef] bg-white p-6"
    >
      <h2 class="mb-3 text-2xl font-bold">Product not found</h2>
      <p class="leading-7 text-[#52627b]">
        This insurance plan could not be found. Return to the available plans.
      </p>
    </section>

    <div
      v-else-if="error"
      class="rounded-xl border border-red-200 bg-white p-6"
      role="alert"
    >
      <p class="text-red-700">{{ error }}</p>
      <button
        type="button"
        class="mt-4 cursor-pointer rounded-lg bg-[#15233b] px-5 py-3 font-semibold text-white hover:bg-slate-700 focus-visible:outline-2 focus-visible:outline-offset-4 focus-visible:outline-blue-600"
        @click="retryCount++"
      >
        Try again
      </button>
    </div>

    <article
      v-else-if="product"
      class="max-w-212.5 rounded-2xl border border-[#dce5ef] bg-white p-6 sm:p-12"
    >
      <p class="mb-4 text-xs font-semibold tracking-widest text-[#52627b] uppercase">
        Insurance plan
      </p>

      <h1 class="mb-8 text-4xl leading-tight font-extrabold tracking-tight wrap-break-word sm:text-5xl">
        {{ product.name }}
      </h1>

      <section aria-labelledby="overview-heading">
        <h2 id="overview-heading" class="mb-3 text-xl font-bold">Overview</h2>
        <p class="text-lg leading-8 whitespace-pre-line text-[#52627b]">
          {{ product.description }}
        </p>
      </section>

      <section
        v-for="section in detailSections"
        :key="section.key"
        class="mt-7 border-t border-[#dce5ef] pt-7"
        :aria-labelledby="`${section.key}-heading`"
      >
        <h2 :id="`${section.key}-heading`" class="mb-3 text-xl font-bold">
          {{ section.title }}
        </h2>

        <p
          v-if="hasDetails(product[section.key])"
          class="leading-8 wrap-break-words whitespace-pre-line text-[#52627b]"
        >
          {{ product[section.key] }}
        </p>

        <p v-else class="text-[#52627b] italic">
          Details not yet provided.
        </p>
      </section>

      <div class="mt-9">
        <button
          v-if="!showQuoteForm"
          type="button"
          class="cursor-pointer rounded-lg bg-[#15233b] px-5 py-3 font-semibold text-white hover:bg-slate-700 focus-visible:outline-2 focus-visible:outline-offset-4 focus-visible:outline-blue-600"
          @click="showQuoteForm = true"
        >
          Request a quote
        </button>

        <QuoteRequestForm
          v-if="showQuoteForm"
          :key="product.id"
          :product-id="product.id"
        />
      </div>
    </article>
  </main>
</template>