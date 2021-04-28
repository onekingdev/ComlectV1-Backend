import init from './vue/init'
import store from '@/store/common'
import SignupPage from './vue/auth/SignUp/Page.vue'
import SigninPage from './vue/auth/SingIn/Page.vue'
import ResetPasswordPage from './vue/auth/ResetPassword/Page.vue'
import SpecialistOnboardingPage from './vue/auth/SignUp/Onboarding/Specialist/SpecialistPage.vue'
import BusinessOnboardingPage from './vue/auth/SignUp/Onboarding/Business/BusinessPage.vue'

init({
  store,
  components: {
    SignupPage,
    SigninPage,
    ResetPasswordPage,
    SpecialistOnboardingPage,
    BusinessOnboardingPage
  }
})
