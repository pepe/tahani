(import test/helper :prefix "" :exit true)

(import ../build/tahani :as t)

(import ../tahani/store :as ts)
(import ../tahani/utils :as tu)

(start-suite 1)

#@todo split
(defer (t/manage/destroy "peopletest")
  (with [s (ts/create "peopletest" [:name :job :pet])]
        (assert s "Store is not created")
        (def id (:save s {:name "Pepe" :job "Programmer" :pet "Cat"}))
        (assert id "Record is not saved")
        (assert (string? id) "Record id is not string")
        (def r (:load s id))
        (assert r "Record is not loaded")
        (assert (struct? r) "Record is not struct")
        (assert (= (r :name) "Pepe") "Record has bad name")

        # @todo transactions
        (:save s {:name "Jose" :job "Programmer" :pet "Cat"})
        (:save s {:name "Karl" :job "Gardener" :pet "Dog"})
        (:save s {:name "Pepe" :job "Gardener" :pet "Dog"})
        (:save s {:name "Joker" :job "Gardener" :pet "" :good-deeds []})
        (def rs (:find-by s :name "Pepe"))
        (assert (array? rs) "Records are not found by find-by")
        (assert (= (length rs) 2) "Not all records are not found by find-by")
        (each ro rs (assert (= (ro :name) "Pepe") "Record with other name is found by find-by"))
        (def ra (:find-all s {:job "Programmer" :name "Pepe"}))
        (assert (array? ra) "Records are not found")
        (assert (all |(array? $) ra) "Records are not in sets")
        (assert (all (fn [set] (find |(= ($ :name) "Pepe") set)) ra) "Record is not in both sets")
        (def ru (tu/union (:find-all s {:job "Programmer" :name "Pepe"})))
        (assert ru "Sets are not in union")
        (assert (= (length ru) 3) "Not all records are not unioned")
        (def ri (tu/intersect (:find-all s {:job "Programmer" :name "Pepe"})))
        (assert ri "Sets are not in intersection")
        (assert (= (length ri) 1) "Records are not intersected right")))
(end-suite)

