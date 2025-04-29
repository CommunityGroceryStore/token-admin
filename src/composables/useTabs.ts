import { ref } from 'vue'

export type Tab = {
  id: string
  title: string
  icon: any
}

export function useTabs() {
  const tabs = ref<Tab[]>([
    {
      id: 'stories',
      title: 'Stories',
      icon: 'FileText'
    },
    {
      id: 'votes',
      title: 'Votes',
      icon: 'Vote'
    }
  ])

  const activeTab = ref(tabs.value[0].id)

  const setActiveTab = (tabId: string) => {
    activeTab.value = tabId
  }

  return {
    tabs,
    activeTab,
    setActiveTab
  }
}