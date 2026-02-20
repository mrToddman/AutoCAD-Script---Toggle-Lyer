;; ===============================================================
;; Layer ON/OFF by case-insensitive substring match
;; Groups covered by commands:
;;   DEMO      → matches "demo" and "(d)"
;;   NEW       → matches "new" and "(n)"
;;   PROPOSED  → matches "proposed" and shorthand "prop" (guards against "property")
;;   EXIST     → matches "exist" and "(e)"
;;
;; Commands:
;;   DEMO-ON       / DEMO-OFF
;;   NEW-ON        / NEW-OFF
;;   PROPOSED-ON   / PROPOSED-OFF
;;   EXIST-ON      / EXIST-OFF
;;
;; Notes:
;;   - Matches are substring-based and case-insensitive.
;;   - Xref-dependent layers are included (e.g., "XREF|A-DEMO-WALLS").
;;   - Uses the LayerOn property (does not freeze/thaw).
;;   - Safe: does NOT override AutoCAD’s built-in NEW command.
;;   - For PROPOSED: "PROP" will NOT match "PROPERTY" (to avoid false positives).
;; ===============================================================

(vl-load-com)

;; --------------------------
;; Config: tags per group
;; --------------------------
(setq *layer-tag-groups*
  '(("DEMO"     . ("DEMO" "(D)"))
    ("NEW"      . ("NEW" "(N)"))
    ("PROPOSED" . ("PROPOSED" "PROP"))  ;; includes shorthand "PROP"
    ("EXIST"    . ("EXIST" "(E)"))
  )
)

;; --------------------------
;; Helpers
;; --------------------------

(defun _str-contains-ci (s sub /)
  "Case-insensitive substring check."
  (and s sub
       (not (null (vl-string-search (strcase sub) (strcase s))))))

(defun _has-any-tag (name tags / lname hit tag)
  "Returns T if NAME contains any of TAGS (case-insensitive)."
  (setq lname (strcase name)
        hit   nil)
  (foreach tag tags
    (if (and (not hit) (vl-string-search (strcase tag) lname))
      (setq hit T)
    )
  )
  hit)

(defun _acad-doc () (vla-get-ActiveDocument (vlax-get-Acad-Object)))

(defun _toggle-by-group (group-key turn-on / doc layers tags lay nm cnt err match?)
  "Turn ON (turn-on=T) or OFF (turn-on=nil) all layers whose names contain
   any of the tags defined for GROUP-KEY."
  (setq tags (cdr (assoc group-key *layer-tag-groups*)))
  (if (not tags)
    (prompt (strcat "\n[Error] No tags defined for key: " group-key))
    (progn
      (setq doc    (_acad-doc)
            layers (vla-get-Layers doc)
            cnt    0
      )
      (vlax-for lay layers
        (setq nm (vla-get-Name lay))

        ;; ---- Special handling for PROPOSED to avoid "PROPERTY" false matches
        (setq match?
          (if (= group-key "PROPOSED")
            (or (_str-contains-ci nm "PROPOSED")
                (and (_str-contains-ci nm "PROP")
                     (not (_str-contains-ci nm "PROPERTY"))))
            (_has-any-tag nm tags)
          )
        )

        (if match?
          (progn
            (setq err
              (vl-catch-all-apply
                '(lambda ()
                   (vla-put-LayerOn lay (if turn-on :vlax-true :vlax-false))
                 )
              )
            )
            (if (vl-catch-all-error-p err)
              (prompt (strcat "\n  Skipped (error): " nm " — " (vl-catch-all-error-message err)))
              (setq cnt (1+ cnt))
            )
          )
        )
      )
      (prompt
        (strcat
          "\n" group-key " layers turned "
          (if turn-on "ON" "OFF")
          ": " (itoa cnt)
        )
      )
    )
  )
  (princ)
)

;; --------------------------
;; Commands (exact names requested)
;; --------------------------

(defun c:DEMO-ON      () (_toggle-by-group "DEMO" T))
(defun c:DEMO-OFF     () (_toggle-by-group "DEMO" nil))

(defun c:NEW-ON       () (_toggle-by-group "NEW" T))
(defun c:NEW-OFF      () (_toggle-by-group "NEW" nil))

(defun c:PROPOSED-ON  () (_toggle-by-group "PROPOSED" T))
(defun c:PROPOSED-OFF () (_toggle-by-group "PROPOSED" nil))

(defun c:EXIST-ON     () (_toggle-by-group "EXIST" T))
(defun c:EXIST-OFF    () (_toggle-by-group "EXIST" nil))

(princ "\nLoaded: DEMO-ON/OFF, NEW-ON/OFF, PROPOSED-ON/OFF (PROP included), EXIST-ON/OFF.")
(princ)