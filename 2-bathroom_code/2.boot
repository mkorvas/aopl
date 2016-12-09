#!/usr/bin/env boot

(require '[clojure.java.io :refer [reader]])
(require '[clojure.string :refer [join]])

(def keypad
  (vector
    "  1  "
    " 234 "
    "56789"
    " ABC "
    "  D  "))
(def no-key \space)
(def start [2 0])

(defn clip [min-val max-val val]
  (min max-val (max min-val val)))

(defn clipped-add [min-val max-val & args]
  (clip min-val max-val (apply + args)))

(defn get-key [p]
  (get-in keypad p))

(def move-funs
  (letfn [(step [p d]
            (let [newp (into [] (map (partial clipped-add 0 4) p d))]
              (if (= (get-key newp) no-key) p newp)))]
    {\U #(step % [-1 0])
     \R #(step % [0 1])
     \D #(step % [1 0])
     \L #(step % [0 -1])})
)

(defn move [p c]
  ((move-funs c) p))

(defn proc-line [h l]
  (let [p (reduce move (last h) l)]
    (conj h p)))

(defn get-code [infile]
  (with-open [rdr (reader infile)]
    (->> (line-seq rdr)
         (reduce proc-line [start])
         rest
         (map get-key)
         (join "")
         println
)))

(defn -main [infile]
  (get-code infile))
