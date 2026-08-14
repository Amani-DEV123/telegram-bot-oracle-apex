BEGIN
    DBMS_SCHEDULER.CREATE_JOB (
        job_name        => 'TELEGRAM_CHECK_JOB',
        job_type        => 'STORED_PROCEDURE',
        job_action      => 'CHECK_TELEGRAM_MESSAGES',
        start_date      => SYSTIMESTAMP,
        repeat_interval => 'FREQ=SECONDLY;INTERVAL=10',
        enabled         => TRUE,
        auto_drop       => FALSE
    );
END;
/
