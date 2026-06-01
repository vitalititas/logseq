(ns frontend.components.onboarding
  (:require [frontend.context.i18n :refer [t]]
            [frontend.state :as state]
            [frontend.ui :as ui]))

(defn help
  []
  [:div.help.cp__sidebar-help-docs
   (let [discourse-with-icon [:div.flex-row.inline-flex.items-center
                              [:span.mr-1 (t :help/forum-community)]
                              (ui/icon "message-circle" {:style {:font-size 20}})]
         list
         [{:title (t :help/usage-title)
           :children [[[:a
                        {:on-click (fn [] (state/sidebar-add-block! (state/get-current-repo) "shortcut-settings" :shortcut-settings))}
                        [:div.flex-row.inline-flex.items-center
                         [:span.mr-1 (t :help.shortcuts/label)]
                         (ui/icon "command" {:style {:font-size 20}})]]]
                      [(t :help/docs) "https://github.com/vitalititas/logseq"]
                      [(t :help/start) "https://github.com/vitalititas/logseq"]
                      ["FAQ" "https://github.com/vitalititas/logseq/issues"]]}

          {:title (t :help/community-title)
           :children [[(t :help/awesome-logseq) "https://github.com/vitalititas/logseq"]
                      [(t :help/blog) "https://github.com/vitalititas/logseq"]
                      [discourse-with-icon "https://github.com/vitalititas/logseq/discussions"]]}

          {:title (t :help/development-title)
           :children [[(t :help/roadmap) "https://github.com/vitalititas/logseq/projects"]
                      [(t :help/bug) "https://github.com/vitalititas/logseq/issues/new"]
                      [(t :help/feature) "https://github.com/vitalititas/logseq/issues/new"]
                      [(t :help/changelog) "https://github.com/vitalititas/logseq/releases"]]}

          {:title (t :help/about-title)
           :children [[(t :help/about) "https://github.com/vitalititas/logseq"]]}

          {:title (t :help/terms-title)
           :children [[(t :help/privacy) "https://github.com/vitalititas/logseq"]
                      [(t :help/terms) "https://github.com/vitalititas/logseq"]]}]]

     (map (fn [sublist]
            [[:p.mt-4.mb-1 [:b (:title sublist)]]
             [:ul
              (map (fn [[title href]]
                     [:li
                      (if href
                        [:a {:href href :target "_blank"} title]
                        title)])
                   (:children sublist))]])
          list))])
