;;; .dir-locals.el ---  Project variable setting. -*- lexical-binding: t; -*-

;; Copyright (C) 2024 lyt0628

;;; Commentary:

;;; Code:


((org-mode .
           ((org-babel-default-header-args .
                                           ((:session . "none")
                                            (:results . "replace")
                                            (:exports . "code")
                                            (:eval . "no")
                                            (:cache . "no")
                                            (:noweb . "strip-export")
                                            (:comments . "both")
                                            (:hlines . "no")
                                            (:tangle . "no"))))))
                                          





;;; .dir-locals.el ends here
