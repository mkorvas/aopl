#!boot -f

(require '[clojure.java.io :refer [reader]])

(def strides [1 3 5 7 1/2])

(defn char-idxs [stride]
  (map #(* stride %) (range)))

(defn char-at-wrapped [i s]
  (if (not= (mod i 1) 0)
    nil
    (get s (mod i (count s)))))

(defn count-trees [stride lines]
  (->> lines
       (map char-at-wrapped (char-idxs stride))
       (remove nil?)
       (filter #(= \# %))
       count))

(def tree-counters
  (apply juxt
         (map #(partial count-trees %)
              strides)))

(defn get-code [infile]
  (with-open [rdr (reader infile)]
    (->> rdr
         line-seq
         tree-counters
         (reduce *)
         println
)))

(defn -main [infile]
  (get-code infile))
