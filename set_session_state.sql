create or replace PROCEDURE set_session_state (
    p_chat_id VARCHAR2,
    p_state   VARCHAR2
)
IS
BEGIN

    UPDATE telegram_session
    SET session_state = p_state,
        updated_date  = SYSDATE
    WHERE chat_id = p_chat_id;

    COMMIT;

END set_session_state;
/