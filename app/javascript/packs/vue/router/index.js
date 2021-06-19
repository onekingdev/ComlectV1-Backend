import Vue from 'vue'
import Router from 'vue-router'
// import AuthGuard from './auth-guard'
import Dashboard from '@/business/dashboard/Page'
import Policies from '@/business/policies/Page'
import AnnualReviews from '@/business/annual/Page'
import Risks from '@/business/riskregister/Page'
import ReportsRisks from '@/business/reportsrisks/Page'
import FileFolders from '@/business/filefolders/Page'
import Exams from '@/business/exammanagement/Page'

Vue.use(Router)

export default new Router({
  routes: [
    {
      path: '/business',
      name: 'dashboard',
      component: Dashboard
    },
    {
      path: '/business/compliance_policies',
      name: 'policies',
      component: Policies
    },
    {
      path: '/business/compliance_policies/:policy-id',
      name: 'policies',
      props: true,
      component: Policies
    },
    {
      path: '/business/annual_reviews',
      name: 'annual-reviews',
      component: AnnualReviews
    },
    {
      path: '/business/risks',
      name: 'risks',
      component: Risks
    },
    {
      path: '/business/file_folders',
      name: 'file-folders',
      component: FileFolders
    },
    {
      path: '/business/exam_management',
      name: 'exam-management',
      component: Exams
    },
    {
      path: '/business/reports/risks',
      name: 'reports-risks',
      component: ReportsRisks
    },
  ],
  mode: 'history'
})
