#!boot -f

(require '[clojure.java.io :refer [reader]])

(defn char-idxs []
  (map #(* 3 %) (range)))

(defn char-at-wrapped [i s]
  (get s (mod i (count s))))

(defn get-code [infile]
  (with-open [rdr (reader infile)]
    (->> rdr
         line-seq
         (map char-at-wrapped (char-idxs))
         (filter #(= \# %))
         count
         println
)))

(defn -main [infile]
  (get-code infile))
