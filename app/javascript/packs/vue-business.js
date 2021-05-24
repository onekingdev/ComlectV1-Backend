import init from './vue/init'
import store from '@/store/business'
import BusinessDashboardPage from './vue/business/dashboard/Page.vue'
import BusinessRemindersPage from './vue/business/reminders/Page.vue'
import BusinessPostProjectPage from './vue/business/projects/PostProjectPage.vue'
import BusinessProjectsPage from './vue/business/projects/Page.vue'
import ProjectShowPage from '@/business/projects/ShowPage'
import ProjectShowPostPage from '@/business/projects/ShowPostPage'
import RemindersPage from '@/business/reminders/Page'
import TimesheetsShowPage from '@/business/projects/TimesheetsShowPage'
import BusinessAnnualsPage from './vue/business/annual/Page.vue'
import BusinessAnnualReviewPage from './vue/business/annual/PageCurrentReviewCategory.vue'
import BusinessAnnualGeneralPage from './vue/business/annual/PageCurrentGeneral.vue'

import BusinessPoliciesPage from './vue/business/policies/Page.vue'
import BusinessPoliciesCreatePage from './vue/business/policies/Details/PolicyCreate.vue'

const businesPolicies = {
  BusinessPoliciesPage,
  BusinessPoliciesCreatePage,
}

import BusinessMarketplacePage from './vue/business/marketplace/Page.vue'

const businesMarketplace = {
  BusinessMarketplacePage,
}

import BusinessReportsRisksPage from './vue/business/reportsrisks/Page.vue'

const BusinessReportsRisks = {
  BusinessReportsRisksPage,
}

import BusinessRisksPage from './vue/business/riskregister/Page.vue'
import BusinessRisksPageDetail from './vue/business/riskregister/RiskDetail.vue'

const businesRisks = {
  BusinessRisksPage,
  BusinessRisksPageDetail
}

import BusinessFileFoldersPage from './vue/business/filefolders/Page.vue'

const BusinessFileFolders = {
  BusinessFileFoldersPage,
}

import BusinessExamManagementPage from './vue/business/exammanagement/Page.vue'
import BusinessExamManagementShowPage from './vue/business/exammanagement/PageCurrentReviewExam.vue'
import BusinessExamManagementAuditorPortalShowPage from './vue/business/exammanagement/PageAuditorPortal.vue'

const BusinessExamManagement = {
  BusinessExamManagementPage,
  BusinessExamManagementShowPage,
  BusinessExamManagementAuditorPortalShowPage,
}


init({
  store,
  components: {
    BusinessDashboardPage,
    BusinessRemindersPage,
    BusinessProjectsPage,
    BusinessPostProjectPage,
    ProjectShowPage,
    ProjectShowPostPage,
    RemindersPage,
    TimesheetsShowPage,
    BusinessAnnualsPage,
    BusinessAnnualReviewPage,
    BusinessAnnualGeneralPage,
    ...businesPolicies,
    ...BusinessReportsRisks,
    ...businesRisks,
    ...businesMarketplace,
    ...BusinessFileFolders,
    ...BusinessExamManagement,
  }
})
