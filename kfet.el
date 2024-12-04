;;; kfet.el --- Montre dans la mode-line si la K-Fêt est ouverte. -*- lexical-binding: t; -*-

;; Copyright (C) 2024 Aghilas Y. Boussaa

;; Author: Aghilas Y. Boussaa <aghilas.boussaa@ens.psl.eu>

;; SPDX-License-Identifier: GPL-3.0-or-later

;; kfet.el is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published
;; by the Free Software Foundation, either version 3 of the License,
;; or (at your option) any later version.
;;
;; kfet.el is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;;; Commentary:

;;; Code:

(require 'websocket)

(defvar kfet-closed-prompt " K-Fêt : fermée "
  "Chaîne à afficher quand la K-Fêt est fermée.")

(defvar kfet-opened-prompt " K-Fêt : ouverte "
  "Chaîne à afficher quand la K-Fêt est fermée.")

(defvar kfet-status nil
  "Statut de la K-Fêt.")

(defvar kfet-websocket nil
  "Websocket connectant Emacs à la K-Fêt.")

(define-minor-mode display-kfet-mode
  "Affiche le statut de la K-Fêt dans la mode-line."
  :init-value nil
  
  (unless mode-line-misc-info
    (setq mode-line-misc-info '("")))
  (if display-kfet-mode
      (progn
        (setq kfet-websocket
              (websocket-open
               "wss://kfet.sinavir.fr/ws/"
               :on-message
               (lambda (ws frame)
                 (setq kfet-status
                       (if
                           (equal (cdar (json-read-from-string (websocket-frame-text frame)))
                                  "opened")
                           kfet-opened-prompt kfet-closed-prompt)))))
        (add-to-list 'mode-line-misc-info 'kfet-status 'APPEND))
    (setq mode-line-misc-info (delq 'kfet-status
                                    mode-line-misc-info))
    (websocket-close kfet-websocket)))

(provide 'display-kfet-mode)

;;; kfet.el ends here
