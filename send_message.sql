create or replace PROCEDURE    send_message (
        p_chat_id VARCHAR2,
        p_text    VARCHAR2
    ) IS
    V_token       CONSTANT VARCHAR2(200) := GET_BOT_TOKEN;
    V_response    CLOB;
    V_send_resp   CLOB;
    V_json        CLOB;

 
    BEGIN

        apex_json.initialize_clob_output;

        apex_json.open_object;

        apex_json.write(
            'chat_id',
            p_chat_id
        );

        apex_json.write(
            'text',
            p_text
        );

        apex_json.close_object;

        V_json := apex_json.get_clob_output;

        apex_json.free_output;


        apex_web_service.g_request_headers(1).name :=
            'Content-Type';

        apex_web_service.g_request_headers(1).value :=
            'application/json; charset=UTF-8';


        V_send_resp := apex_web_service.make_rest_request(
            p_url =>
                'https://api.telegram.org/bot' || V_token ||
                '/sendMessage',

            p_http_method => 'POST',

            p_body => V_json
        );



    END send_message;
/