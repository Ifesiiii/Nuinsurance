<template>
  <div class="min-h-screen bg-[#eef3f8] font-sans text-[#15233b] antialiased">
    <header class="border-b border-[#dce5ef] bg-white">
      <div
        class="mx-auto flex min-h-22 max-w-[1244px] items-center gap-3 px-5 sm:px-8"
      >
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