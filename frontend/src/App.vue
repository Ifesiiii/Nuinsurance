<template>
  <div class="min-h-screen bg-[#eef3f8] font-sans text-[#15233b] antialiased">
    <header class="border-b border-[#dce5ef] bg-white">
      <div
        class="mx-auto flex min-h-22 max-w-[1244px] items-center gap-3 px-5 sm:px-8"
      >
        <span
          class="grid h-11 w-10 shrink-0 place-items-center rounded-xl bg-[#15233b] text-white"
          aria-hidden="true"
        >
          <svg
            class="h-7 w-7"
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

        <RouterLink
          to="/products"
          class="rounded text-2xl font-extrabold tracking-tight focus-visible:outline-2 focus-visible:outline-offset-4 focus-visible:outline-blue-600"
        >
          nuinsurance
        </RouterLink>
      </div>
    </header>

    <RouterView />
  </div>
</template>