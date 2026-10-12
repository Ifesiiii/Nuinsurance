<script setup>
import { computed, ref, watch } from 'vue'
import { useRoute } from 'vue-router'

const route = useRoute()

const request = ref(null)
const loading = ref(true)
const error = ref('')
const notFound = ref(false)
const refreshCount = ref(0)

const statuses = {
  pending: {
    label: 'Pending',
    description: 'Your request is awaiting review.',
    classes: 'bg-amber-100 text-amber-900',
  },
  in_review: {
    label: 'In review',
    description: 'Your request is being reviewed.',
    classes: 'bg-blue-100 text-blue-900',
  },
  responded: {
    label: 'Responded',
    description: 'A response is available below.',
    classes: 'bg-green-100 text-green-900',
  },
}

const statusInfo = computed(() => {
  return statuses[request.value?.status] || {
    label: 'Status unavailable',
    description: 'Please check again later.',
    classes: 'bg-slate-100 text-slate-700',
  }
})

const quote = computed(() => request.value?.response ?? null)

function formatDateTime(value) {
  if (!value) return 'Not provided'

  const date = new Date(value)
  if (Number.isNaN(date.getTime())) return 'Not provided'

  return new Intl.DateTimeFormat('en-NG', {
    dateStyle: 'medium',
    timeStyle: 'short',
  }).format(date)
}

function formatExpiryDate(value) {
  if (!value) return 'Not provided'

  // Treat the date as a calendar date, without shifting time zones.
  const date = new Date(`${value}T00:00:00Z`)
  if (Number.isNaN(date.getTime())) return 'Not provided'

  return new Intl.DateTimeFormat('en-NG', {
    dateStyle: 'long',
    timeZone: 'UTC',
  }).format(date)
}

function formatMoney(amount, currency) {
  return new Intl.NumberFormat('en-NG', {
    style: 'currency',
    currency,
    minimumFractionDigits: 2,
    maximumFractionDigits: 2,
  }).format(Number(amount))
}

watch(
  [() => route.params.token, refreshCount],
  async ([token], _previous, onCleanup) => {
    const controller = new AbortController()
    onCleanup(() => controller.abort())

    loading.value = true
    error.value = ''
    notFound.value = false
    request.value = null

    try {
      const response = await fetch(
        `/api/quote_requests/tracks/${encodeURIComponent(token)}`,
        {
          headers: { Accept: 'application/json' },
          cache: 'no-store',
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

      if (
        !result.data ||
        typeof result.data.product_name !== 'string' ||
        typeof result.data.status !== 'string'
      ) {
        throw new Error('Unexpected tracking response')
      }

      request.value = result.data
    } catch (err) {
      if (controller.signal.aborted) return

      error.value =
        'We could not load your request. Please try again.'
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
  <main class="mx-auto max-w-[1000px] px-5 pt-10 pb-20 sm:px-8">
    <RouterLink
      to="/products"
      class="mb-8 inline-block rounded font-semibold text-[#2f49e0] hover:underline focus-visible:outline-2 focus-visible:outline-offset-4 focus-visible:outline-blue-600"
    >
      ← Browse insurance plans
    </RouterLink>

    <h1 class="mb-3 text-3xl font-extrabold tracking-tight sm:text-4xl">
      Your quote request
    </h1>

    <p class="mb-8 leading-7 text-[#52627b]">
      Bookmark this page to return later. Keep the link private:
      anyone with it can view your request’s progress and quote.
    </p>

    <p
      v-if="loading"
      role="status"
      class="rounded-2xl border border-[#dce5ef] bg-white p-6"
    >
      Loading your request…
    </p>

    <section
      v-else-if="notFound"
      class="rounded-2xl border border-[#dce5ef] bg-white p-6"
    >
      <h2 class="mb-3 text-xl font-bold">Request not found</h2>
      <p class="leading-7 text-[#52627b]">
        Check that you opened the complete tracking link provided
        after submitting your request.
      </p>
    </section>

    <div
      v-else-if="error"
      role="alert"
      class="rounded-2xl border border-red-200 bg-white p-6"
    >
      <p class="text-red-700">{{ error }}</p>

      <button
        type="button"
        class="mt-4 cursor-pointer rounded-lg bg-[#15233b] px-5 py-3 font-semibold text-white hover:bg-slate-700 focus-visible:outline-2 focus-visible:outline-offset-4 focus-visible:outline-blue-600"
        @click="refreshCount++"
      >
        Try again
      </button>
    </div>

    <div v-else-if="request" class="space-y-6">
      <section
        aria-labelledby="progress-heading"
        class="rounded-2xl border border-[#dce5ef] bg-white p-6 sm:p-8"
      >
        <div class="flex flex-wrap items-center justify-between gap-4">
          <h2 id="progress-heading" class="text-xl font-bold">
            Request #{{ request.id }}
          </h2>

          <span
            class="rounded-full px-3 py-1 text-sm font-semibold"
            :class="statusInfo.classes"
          >
            {{ statusInfo.label }}
          </span>
        </div>

        <dl class="mt-6 grid gap-6 sm:grid-cols-2">
          <div>
            <dt class="text-sm text-[#52627b]">Product</dt>
            <dd class="mt-1 text-lg font-semibold">
              {{ request.product_name }}
            </dd>
          </div>

          <div>
            <dt class="text-sm text-[#52627b]">Submitted</dt>
            <dd class="mt-1 font-semibold">
              {{ formatDateTime(request.submitted_at) }}
            </dd>
          </div>
        </dl>

        <p class="mt-6 leading-7 text-[#52627b]">
          {{ statusInfo.description }}
        </p>

        <button
          type="button"
          class="mt-5 cursor-pointer rounded-lg border border-slate-300 px-4 py-2 font-semibold hover:bg-slate-50 focus-visible:outline-2 focus-visible:outline-offset-4 focus-visible:outline-blue-600"
          @click="refreshCount++"
        >
          Refresh progress
        </button>
      </section>

      <section
        aria-labelledby="response-heading"
        class="rounded-2xl border border-[#dce5ef] bg-white p-6 sm:p-8"
      >
        <h2 id="response-heading" class="mb-5 text-xl font-bold">
          Broker’s response
        </h2>

        <p v-if="!quote" class="leading-7 text-[#52627b]">
          Awaiting a broker response. You can return to this page
          to check for updates.
        </p>

        <div v-else>
          <div
            v-if="quote.expired"
            class="mb-6 rounded-xl border border-amber-200 bg-amber-50 p-4 text-amber-900"
          >
            This quote has expired. A renewed quote is needed before
            proceeding.
          </div>

          <p class="text-sm text-[#52627b]">Quoted amount</p>
          <p class="mt-2 text-3xl font-extrabold tracking-tight">
            {{ formatMoney(quote.amount, quote.currency) }}
          </p>

          <dl class="mt-6 grid gap-6 sm:grid-cols-2">
            <div>
              <dt class="text-sm text-[#52627b]">Coverage period</dt>
              <dd class="mt-1 font-semibold">
                {{ quote.coverage_period }}
              </dd>
            </div>

            <div>
              <dt class="text-sm text-[#52627b]">Quote valid through</dt>
              <dd class="mt-1 font-semibold">
                {{ formatExpiryDate(quote.expires_on) }}
              </dd>
            </div>
          </dl>

          <div class="mt-7 border-t border-[#dce5ef] pt-6">
            <h3 class="mb-3 font-bold">Message from the broker</h3>
            <p class="leading-8 break-words whitespace-pre-line text-[#52627b]">
              {{ quote.message }}
            </p>
          </div>

          <p class="mt-6 text-sm text-[#52627b]">
            Responded: {{ formatDateTime(quote.responded_at) }}
          </p>
        </div>
      </section>
    </div>
  </main>
</template>