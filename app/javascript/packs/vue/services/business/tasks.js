import axios from '../../services/axios'
import store from '../../store/business'

const END_POINT_OVERDUE = '/overdue_reminders'
const END_POINT = '/reminders'

export async function getTasks() {
  return axios
    .get(`${END_POINT}`)
    .then(response => {
      if (response) {
        return response
      }
      return response
    })
    .catch(err => err)
}

export async function getTasksByDate(payload) {
  return axios
    .get(`${END_POINT}/${payload}`)
    .then(response => {
      if (response) {
        return response
      }
      return response
    })
    .catch(err => err)
}

export async function getOverdueTasks() {
  return axios
    .get(`${END_POINT_OVERDUE}`)
    .then(response => {
      if (response) {
        return response
      }
      return response
    })
    .catch(err => err)
}

export async function createTask(payload) {
  return await axios.post(`${END_POINT}${payload.occurenceParams}`, payload)
    .then(response => {
      if (response) {
        return response
      }
      return false
    })
    .catch(err => err)
}

export async function updateTask(payload) {
  return await axios.post(`${END_POINT}/${payload.id}`, payload.task)
    .then(response => {
      if (response) {
        return response
      }
      return false
    })
    .catch(err => err)
}

export async function updateTaskStatus(payload) {
  return await axios.post(`${END_POINT}/${payload.id}?done=${payload.done}${payload.oidParam}${payload.src_id_params}`)
    .then(response => {
      if (response) {
        return response
      }
      return false
    })
    .catch(err => err)
}

export async function deleteTask(payload) {
  return await axios.delete(`${END_POINT}/${payload.id}${payload.occurenceParams}`, payload)
    .then(response => {
      if (response) {
        return response
      }
      return false
    })
    .catch(err => err)
}

export async function getTaskById(payload) {
  return await axios.get(`${END_POINT}/${payload}`)
    .then(response => {
      if (response) {
        return response
      }
      return false
    })
    .catch(err => err)
}

export async function getTaskMessagesById(payload) {
  return await axios.get(`${END_POINT}/${payload.id}/messages`)
    .then(response => {
      if (response) {
        return response
      }
      return false
    })
    .catch(err => err)
}

export async function postTaskMessageById(payload) {
  return await axios.post(`${END_POINT}/${payload.id}/messages`, payload.message)
    .then(response => {
      if (response) {
        return response
      }
      return false
    })
    .catch(err => err)
}
