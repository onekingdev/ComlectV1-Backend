import Vue from 'vue'
import Router from 'vue-router'
import AuthGuard from './auth-guard'

// COMMON
import PageNotFound from '@/common/PageNotFound'
import AccessDenied from '@/common/AccessDenied'
import PaymentRequired from '@/common/PaymentRequired'

// AUTH
import SignIn from '@/auth/SingIn/Page'
import SignUp from '@/auth/SignUp/Page'
import SignUpEmployee from '@/auth/SignUp/Employee/Page'
import ResetPassword from '@/auth/ResetPassword/Page'
import ChangePassword from '@/auth/ChangePassword/Page'
import Verification from '@/auth/components/OtpConfirm'
import BusinessOnboarding from '@/auth/SignUp/Onboarding/Business/BusinessPage'
import SpecialistOnboarding from '@/auth/SignUp/Onboarding/Specialist/SpecialistPage'

// BUSINESS
import Dashboard from '@/business/dashboard/Page'
import Projects from '@/business/projects/Page'
import ProjectReview from '@/business/projects/ShowPage'
import PostProjectPage from '@/business/projects/PostProjectPage'
import ShowPostPage from '@/business/projects/ShowPostPage'
import ProjectTimesheetsShowPage from '@/business/projects/TimesheetsShowPage'
import Tasks from '@/business/tasks/Page'
import Policies from '@/business/policies/Page'
import PoliciesEntire from '@/business/policies/PoliciesEntire'
import PolicyCurrent from '@/business/policies/Details/PolicyCreate'
import PolicyCurrentNoSections from '@/business/policies/Details/PolicyDetailsWithoutSections'
import AnnualReviews from '@/business/annual/Page'
import AnnualReviewsCurrentGeneral from '@/business/annual/PageCurrentGeneral'
import AnnualReviewsCurrentReviewCategory from '@/business/annual/PageCurrentReviewCategory'
import Risks from '@/business/riskregister/Page'
import RiskDetail from '@/business/riskregister/RiskDetail'
import ReportsRisks from '@/business/reportsrisks/Page'
import ReportsOrganizations from '@/business/organizations/Page.vue'
import ReportsFinancials from '@/business/financials/Page.vue'
import FileFolders from '@/business/filefolders/Page'
import Exams from '@/business/exams/Page'
import ExamCurrentReview from '@/business/exams/PageCurrentReviewExam'
import Profile from '@/business/profile/Page'
import Settings from '@/business/settings/Page'
import SettingsNotifications from '@/business/notifications/Page'
import SpecialistsMarketplace from '@/business/marketplace/Page'

// SPECIALISTS
import DashboardS from '@/specialist/dashboard/Page'
import ProjectsS from '@/specialist/projects/MyProjectsPage'
import ProjectReviewS from '@/specialist/projects/MyProjectShowPage'
import CreateProposalPage from '@/specialist/projects/CreateProposalPage'
import ProjectTimesheetsPage from '@/specialist/projects/ProjectTimesheetsPage'
import SettingsS from '@/specialist/settings/Page'
import SettingsNotificationsS from '@/specialist/notifications/Page'
import ProjectsMarketplaceS from '@/specialist/projects/IndexPage'
import ProfileS from '@/specialist/profile/Page'
import SpecialistTasksPage from '@/specialist/tasks/Page'

Vue.use(Router)

const paramsToInts = paramNames =>
  route => Object.fromEntries(paramNames.map(paramName => [paramName, +route.params[paramName]]))

export default new Router({
  routes: [
    //NOT FOUND
    { path: "*", component: PageNotFound },

    //ROLES AND PERMISSIONS
    { path: "/access-denied", component: AccessDenied },
    { path: "/payment-required", component: PaymentRequired },

    // REDIRECTS
    // { path: '/business', redirect: '/business/dashboard' },
    // { path: '/business/dashboard', redirect: '/business/dashboard' },
    // { path: '/specialist', redirect: '/specialist/dashboard' },
    // { path: '/specialist/dashboard', redirect: '/specialist/dashboard' },
    { path: '/business/new', redirect: '/business/onboarding' },
    { path: '/specialists/new', redirect: '/specialist/onboarding' },

    // AUTH
    { path: '/', name: 'home', component: SignIn },
    { path: '/users/sign_in', name: 'sign-in', component: SignIn },
    { path: '/users/sign_up', name: 'sign-up', component: SignUp },
    { path: '/employee/new', name: 'sign-up-employee', props: true, component: SignUpEmployee },
    { path: '/users/password/new', name: 'password-new', component: ResetPassword },
    { path: '/users/password/edit', name: 'password-change', component: ChangePassword },
    { path: '/verification', name: 'verification', component: Verification, props: true },
    { path: '/business/onboarding', name: 'business-onboarding', component: BusinessOnboarding, props: true },
    { path: '/businesses/new', name: 'business-onboarding-new', component: BusinessOnboarding, props: true },
    { path: '/specialist/onboarding', name: 'specialist-onboarding', component: SpecialistOnboarding, props: true },
    { path: '/specialist/new', name: 'specialist-onboarding-new', component: SpecialistOnboarding, props: true },

    // BUSINESS
    { path: '/business', name: 'dashboard', component: Dashboard },
    { path: '/business/projects', name: 'projects', component: Projects },
    { path: '/business/projects/:id(\\d+)', name: 'project-review', props: route => ({ projectId: +route.params.id }), component: ProjectReview },
    { path: '/business/projects/:id(\\d+)/timesheets', name: 'project-timesheets', props: route => ({ projectId: +route.params.id }), component: ProjectTimesheetsShowPage },
    { path: '/business/projects/new', name: 'project-post', component: PostProjectPage },
    { path: '/business/projects/new/:id(\\d+)', name: 'project-post-from-local', props: route => ({ localProjectId: +route.params.id }), component: PostProjectPage },
    { path: '/business/project_posts/:id(\\d+)', name: 'project-post-view', props: route => ({ projectId: +route.params.id }), component: ShowPostPage },
    { path: '/business/project_posts/:id(\\d+)/edit', name: 'project-post-edit', props: route => ({ projectId: +route.params.id }), component: PostProjectPage },
    { path: '/business/reminders', name: 'tasks', component: Tasks },
    { path: '/business/compliance_policies', name: 'policies', component: Policies, beforeEnter: AuthGuard },
    { path: '/business/compliance_policies/entire', name: 'policies-entire', props: true, component: PoliciesEntire, beforeEnter: AuthGuard },
    { path: '/business/compliance_policies/:policyId(\\d+)', name: 'policy-current', props: route => ({ policyId: +route.params.policyId, toggleVueEditor: route.params.toggleVueEditor }), component: PolicyCurrentNoSections, beforeEnter: AuthGuard },
    { path: '/business/annual_reviews', name: 'annual-reviews', component: AnnualReviews, beforeEnter: AuthGuard },
    { path: '/business/annual_reviews/:annualId(\\d+)', name: 'annual-reviews-general', props: route => ({ annualId: +route.params.annualId }), component: AnnualReviewsCurrentGeneral, beforeEnter: AuthGuard },
    { path: '/business/annual_reviews/:annualId(\\d+)/:revcatId(\\d+)', name: 'annual-reviews-review-category', props: route => ({ annualId: +route.params.annualId, revcatId: +route.params.revcatId }), component: AnnualReviewsCurrentReviewCategory, beforeEnter: AuthGuard },
    { path: '/business/risks', name: 'risks', component: Risks, beforeEnter: AuthGuard },
    { path: '/business/risks/:riskId(\\d+)', name: 'risk-review', props: route => ({ riskId: +route.params.riskId }), component: RiskDetail, beforeEnter: AuthGuard },
    { path: '/business/file_folders', name: 'file-folders', component: FileFolders, beforeEnter: AuthGuard },
    { path: '/business/exam_management', name: 'exam-management', component: Exams, beforeEnter: AuthGuard },
    { path: '/business/exam_management/:examId(\\d+)', name: 'exam-management-current-review', props: route => ({ examId: +route.params.examId }), component: ExamCurrentReview, beforeEnter: AuthGuard },
    { path: '/business/reports/risks', name: 'reports-risks', component: ReportsRisks, beforeEnter: AuthGuard },
    { path: '/business/reports/organizations', name: 'reports-organizations', component: ReportsOrganizations, beforeEnter: AuthGuard },
    { path: '/business/reports/financials', name: 'reports-financials', component: ReportsFinancials, beforeEnter: AuthGuard },
    { path: '/business/profile', name: 'profile', component: Profile},
    { path: '/business/settings', name: 'settings', component: Settings,
      children:  [
        { path: '/business/settings/general', name: 'settings-general', component: Settings, },
        { path: '/business/settings/users', name: 'settings-users', component: Settings, },
        { path: '/business/settings/roles', name: 'settings-roles', component: Settings, },
        { path: '/business/settings/security', name: 'settings-security', component: Settings, },
        { path: '/business/settings/subscriptions', name: 'settings-subscriptions', component: Settings, },
        { path: '/business/settings/billings', name: 'settings-billings', component: Settings, },
        { path: '/business/settings/notifications', name: 'settings-notifications', component: Settings, }
      ],
    },
    { path: '/business/settings/notification-center', name: 'settings-notification-center', component: SettingsNotifications },
    { path: '/specialistmarketplace', name: 'specialists-marketplace', component: SpecialistsMarketplace },


    // SPECIALISTS
    { path: '/specialist', name: 'dashboard-specialist', component: DashboardS },
    { path: '/specialist/reminders', name: 'tasks-specialist', component: SpecialistTasksPage },
    { path: '/specialist/my-projects', name: 'projects-specialist', component: ProjectsS },
    { path: '/specialist/my-projects/:id(\\d+)', name: 'project-review-specialist', props: paramsToInts(['id']), component: ProjectReviewS },
    { path: '/specialist/settings', name: 'settings-specialist', component: SettingsS,
      children:  [
        { path: '/specialist/settings/general', name: 'settings-general-specialist', component: SettingsS, },
        { path: '/specialist/settings/roles', name: 'settings-roles-specialist', component: SettingsS, },
        { path: '/specialist/settings/security', name: 'settings-security-specialist', component: SettingsS, },
        { path: '/specialist/settings/subscriptions', name: 'settings-subscriptions-specialist', component: SettingsS, },
        { path: '/specialist/settings/billings', name: 'settings-billings-specialist', component: SettingsS, },
        { path: '/specialist/settings/notifications', name: 'settings-notifications-specialist', component: SettingsS, }
      ],
    },
    { path: '/specialist/settings/notification-center', name: 'settings-notification-center-specialist', component: SettingsNotificationsS },
    { path: '/job_board', name: 'projects-marketpalce-specialist', component: ProjectsMarketplaceS },
    { path: '/job_board/:initialOpenId(\\d+)', name: 'projects-marketpalce-specialist-view', props: paramsToInts(['initialOpenId']), component: ProjectsMarketplaceS },
    { path: '/job_board/:projectId(\\d+)/applications/new', name: 'projects-marketplace-create-proposal', props: paramsToInts(['projectId']), component: CreateProposalPage, beforeEnter: AuthGuard },
    { path: '/specialist/my-projects/:id(\\d+)/timesheets', name: 'my-project-timesheet-page', props: paramsToInts(['id']), component: ProjectTimesheetsPage },
    { path: '/specialist/profile', name: 'profile-specialist', component: ProfileS },
  ],
  mode: 'history'
})
