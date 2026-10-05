<script setup>
import { reactive, ref } from 'vue'

const props = defineProps({
  productId: {
    type: Number,
    required: true,
  },
})

const form = reactive({
  name: '',
  email: '',
  message: '',
})

const submitting = ref(false)
const submitted = ref(false)
const errors = ref({})
const errorMessage = ref('')

async function submitRequest() {
  if (submitting.value) return

  submitting.value = true
  errors.value = {}
  errorMessage.value = ''

  try {
    const response = await fetch(
      `/api/products/${props.productId}/quote_requests`,
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          Accept: 'application/json',
        },
        body: JSON.stringify({
          quote_request: {
            name: form.name,
            email: form.email,
            message: form.message,
          },
        }),
      },
    )

    const result = await response.json()

    if (response.status === 422) {
      errors.value = result.errors || {}
      errorMessage.value = 'Please check the form fields below.'
      return
    }

    if (response.status === 404) {
      errorMessage.value = 'This product is no longer available.'
      return
    }

    if (!response.ok) {
      throw new Error(`Request failed: ${response.status}`)
    }

    submitted.value = true
  } catch (err) {
    console.error('Quote request failed:', err)
    errorMessage.value =
      'We could not confirm your submission. Please check your connection before trying again.'
  } finally {
    submitting.value = false
  }
}
</script>

<template>
  <section class="border-t border-[#dce5ef] pt-7" aria-labelledby="quote-heading">
    <h2 id="quote-heading" class="mb-5 text-2xl font-bold">
      Request a quote
    </h2>

    <div
      v-if="submitted"
      class="rounded-xl border border-green-200 bg-green-50 p-6 text-green-900"
      role="status"
    >
      <h3 class="mb-2 text-lg font-bold">Request submitted</h3>
      <p class="leading-7">
        Your quote request has been saved. Pricing will be provided
        after your request is reviewed.
      </p>
    </div>

    <form v-else @submit.prevent="submitRequest">
      <p class="mb-6 leading-7 text-[#52627b]">
        Tell us your name, email address and what you need.
      </p>

      <p
        v-if="errorMessage"
        class="mb-5 rounded-lg bg-red-50 p-4 text-red-700"
        role="alert"
      >
        {{ errorMessage }}
      </p>

      <fieldset :disabled="submitting" class="min-w-0 space-y-6">
        <div>
          <label for="quote-name" class="mb-2 block font-semibold">Name</label>
          <input
            id="quote-name"
            v-model.trim="form.name"
            name="name"
            type="text"
            autocomplete="name"
            maxlength="100"
            required
            :aria-invalid="Boolean(errors.name)"
            :aria-describedby="errors.name ? 'quote-name-error' : undefined"
            class="block w-full rounded-lg border border-slate-300 bg-white px-3 py-3 focus:border-blue-600 focus:ring-2 focus:ring-blue-200 focus:outline-none disabled:bg-slate-100 aria-invalid:border-red-600"
          />
          <p
            v-if="errors.name"
            id="quote-name-error"
            class="mt-2 text-sm text-red-700"
          >
            {{ errors.name.join('. ') }}
          </p>
        </div>

        <div>
          <label for="quote-email" class="mb-2 block font-semibold">Email</label>
          <input
            id="quote-email"
            v-model.trim="form.email"
            name="email"
            type="email"
            autocomplete="email"
            maxlength="254"
            required
            :aria-invalid="Boolean(errors.email)"
            :aria-describedby="errors.email ? 'quote-email-error' : undefined"
            class="block w-full rounded-lg border border-slate-300 bg-white px-3 py-3 focus:border-blue-600 focus:ring-2 focus:ring-blue-200 focus:outline-none disabled:bg-slate-100 aria-invalid:border-red-600"
          />
          <p
            v-if="errors.email"
            id="quote-email-error"
            class="mt-2 text-sm text-red-700"
          >
            {{ errors.email.join('. ') }}
          </p>
        </div>

        <div>
          <label for="quote-message" class="mb-2 block font-semibold">
            What do you need?
          </label>
          <textarea
            id="quote-message"
            v-model.trim="form.message"
            name="message"
            rows="5"
            maxlength="2000"
            required
            :aria-invalid="Boolean(errors.message)"
            :aria-describedby="
              errors.message
                ? 'quote-message-help quote-message-error'
                : 'quote-message-help'
            "
            class="block w-full resize-y rounded-lg border border-slate-300 bg-white px-3 py-3 focus:border-blue-600 focus:ring-2 focus:ring-blue-200 focus:outline-none disabled:bg-slate-100 aria-invalid:border-red-600"
          ></textarea>

          <p id="quote-message-help" class="mt-2 text-sm leading-6 text-[#52627b]">
            Give a brief description. Please do not include medical
            records, payment details or identity documents.
          </p>

          <p
            v-if="errors.message"
            id="quote-message-error"
            class="mt-2 text-sm text-red-700"
          >
            {{ errors.message.join('. ') }}
          </p>
        </div>

        <button
          type="submit"
          class="cursor-pointer rounded-lg bg-[#15233b] px-5 py-3 font-semibold text-white hover:bg-slate-700 focus-visible:outline-2 focus-visible:outline-offset-4 focus-visible:outline-blue-600 disabled:cursor-wait disabled:opacity-60"
        >
          {{ submitting ? 'Submitting…' : 'Submit request' }}
        </button>
      </fieldset>
    </form>
  </section>
</template>