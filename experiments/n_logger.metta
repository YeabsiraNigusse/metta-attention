(register-module! ../../metta-attention)
(import! &self metta-attention:attention:AttentionParam)
!(register-module! ../experiments)

!(python-import "experiments.log" log)

!(bind! start_logger (py-atom log.start_logger))
!(bind! save_params (py-atom log.save_params))
!(bind! write_to_csv (py-atom log.write_to_csv))



(= (write_csv_wrapper $space)
    (let $snapshot
        (collapse (AFsnapshot $space))
        (let $fsnapshot
            (format-args "{}" ($snapshot))
            ; (println! $fsnapshot)
            (write_to_csv $_ $fsnapshot)
        )
    )
)

(= (AFsnapshot $space)
    (let* 
        (
            ($atom (get-atoms $space))
            ($av (getAv $atom))
        ) 
        ($atom $av) 
    )
)

(= (start_log $attentionParam $file)
    (let $param 
        (start_logger $_ $file)
        (let $val
            (collapse (get-atoms $attentionParam))
            (let $fvals
                (format-args "{}" ($val))
                (save_params $_ $fvals)
            )
        )
    )
)