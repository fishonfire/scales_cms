const LocaleInLocalStorage = {
  mounted() {
    if (sessionStorage.getItem('locale')) {
      this.pushEventTo(this.el, "got-locale", { locale: sessionStorage.getItem('locale') })
    }

    this.handleEvent("set-locale", ({ locale }) =>
      sessionStorage.setItem("locale", locale)
    )
  }
}

export default LocaleInLocalStorage
