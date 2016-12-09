#!/usr/bin/env boot

(require '[clojure.java.io :refer [reader]])
(require '[clojure.string :refer [join]])

(def infile "in-ex")

(def move-funs
  {\U #(if (<= % 3) % (- % 3))
   \R #(if (= 0 (mod % 3)) % (inc %))
   \D #(if (>= % 7) % (+ % 3))
   \L #(if (= 1 (mod % 3)) % (dec %))}
)

(defn move [p c]
  ((move-funs c) p))

(defn proc-line [h l]
  (let [p (reduce move (last h) l)]
    (conj h p)))

(defn get-code [infile]
  (with-open [rdr (reader infile)]
    (println (join "" (rest (reduce proc-line [5] (line-seq rdr)))))))

(defn -main [infile]
  (get-code infile))
