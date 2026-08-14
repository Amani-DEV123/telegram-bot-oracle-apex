create or replace PROCEDURE CHECK_TELEGRAM_MESSAGES
IS
   l_token       CONSTANT VARCHAR2(200) := GET_BOT_TOKEN;
    V_response    CLOB;
    V_count       NUMBER;
    V_chat_id     VARCHAR2(100);
    V_text        VARCHAR2(4000);
    V_state       VARCHAR2(50);
    V_update_id   NUMBER;
    V_last_update_id NUMBER;
    V_message     VARCHAR2(32767);


    CURSOR c_ord IS
        SELECT
        order_no,
        customer_name,
        order_date,
        order_status,
        total_amount,
        delivery_address
    FROM sales_order2
    WHERE customer_mobile = V_text
    ORDER BY order_date DESC;


BEGIN

    SELECT NVL(LAST_UPDATE_ID, 0)
    INTO V_last_update_id
    FROM TELEGRAM_BOT_CONTROL
    WHERE ID = 1;

    V_response := apex_web_service.make_rest_request(
        p_url => 'https://api.telegram.org/bot' || l_token ||'/getUpdates?offset=' ||(V_last_update_id + 1),
        p_http_method => 'GET'
    );
    apex_json.parse(V_response);
    V_count := apex_json.get_count('result');


    IF NVL(V_count, 0) = 0 THEN
        DBMS_OUTPUT.PUT_LINE('No new messages.');
        RETURN;
    END IF;

    FOR i IN 1 .. V_count LOOP
        V_update_id := apex_json.get_number(
            p_path => 'result[%d].update_id',
            p0     => i
        );

        V_chat_id := apex_json.get_varchar2(
            p_path => 'result[%d].message.chat.id',
            p0     => i
        );

        V_text := apex_json.get_varchar2(
            p_path => 'result[%d].message.text',
            p0     => i
        );

        V_text := TRIM(V_text);

BEGIN
            SELECT session_state
            INTO V_state
            FROM telegram_session
            WHERE chat_id = V_chat_id;
        EXCEPTION WHEN NO_DATA_FOUND THEN
          V_state := 'MAIN';
          INSERT INTO telegram_session VALUES (
                    V_chat_id, --chat_id
                    'MAIN', --session_state
                    SYSDATE --updated_date
                );
                COMMIT;

        END;
  
   IF V_state = 'MAIN' THEN

      IF V_text = '1' THEN
        set_session_state(
            V_chat_id,
            'ORDER_MENU'
        );
        COMMIT;

        send_message(
        V_chat_id,
        '📦 My Orders' || CHR(10) || CHR(10) ||
        'Choose a search method:' || CHR(10) || CHR(10) ||
        '1️⃣ By Mobile Number' || CHR(10) ||
        '2️⃣ By Order Number'
        );


       ELSE
        send_message(
        V_chat_id,

        'Welcome to my Company' ||
        CHR(10) || CHR(10) ||

        'How can I assist you?' ||
        CHR(10) || CHR(10) ||

        '1️⃣ My Orders' || CHR(10) ||
        '2️⃣ My Invoices' || CHR(10) ||
        '3️⃣ My Dues' || CHR(10) ||
        '4️⃣ Track Order' || CHR(10) ||
        '5️⃣ Download Invoice' || CHR(10) ||
        '6️⃣ My Information' || CHR(10) ||
        '7️⃣ Contact Customer Service' ||
        CHR(10) || CHR(10) ||

        'Please send the number of the required service.'
        );
      END IF;

    ELSIF V_state = 'ORDER_MENU' THEN

        IF V_text = '1' THEN
        set_session_state(
        V_chat_id,
        'WAITING_MOBILE'
        );
      COMMIT;

       send_message(
        V_chat_id,

        '📱 Please enter the mobile number associated with the order.'
        );
    ELSIF V_text = '2' THEN

    set_session_state(
    V_chat_id,
    'WAITING_ORDER_NO'
    );
    COMMIT;

    send_message(
    V_chat_id,

    '📦 Please enter the order number.'
    );


        ELSE


        send_message(
        V_chat_id,

        'Please choose:' ||
        CHR(10) ||
        '1️⃣ By Mobile Number' ||
        CHR(10) ||
        '2️⃣ By Order Number'
        );


    END IF;

    ELSIF V_state = 'WAITING_MOBILE' THEN
            V_message := '';
          FOR r IN c_ord LOOP
                V_message := V_message ||

                    '📦 Order: ' ||
                    NVL(r.order_no, '-') ||
                    CHR(10) ||

                    '👤 Customer: ' ||
                    NVL(r.customer_name, '-') ||
                    CHR(10) ||

                    '📅 Date: ' ||
                    NVL(
                        TO_CHAR(
                            r.order_date,
                            'DD/MM/YYYY'
                        ),
                        '-'
                    ) ||
                    CHR(10) ||

                    '📌 Status: ' ||
                    NVL(r.order_status, '-') ||
                    CHR(10) ||

                    '💰 Total: ' ||
                    NVL(
                        TO_CHAR(
                            r.total_amount,
                            '999,999,990.00'
                        ),
                        '0.00'
                    ) ||
                    ' SAR' ||
                    CHR(10) ||

                    '📍 Address: ' ||
                    NVL(r.delivery_address, '-') ||

                    CHR(10) ||
                    '------------------------' ||
                    CHR(10);

            END LOOP;
            IF V_message IS NULL OR V_message = '' THEN

                V_message :=
                    '❌ No orders were found for the mobile number:' ||
                    CHR(10) ||V_text;

        ELSE
            V_message :=
                '📦 Your Orders:' ||
                CHR(10) ||
                CHR(10) ||
                V_message;
            END IF;

            send_message(
                V_chat_id,
                V_message
            );

            set_session_state(
            V_chat_id,
            'MAIN'
            );

            COMMIT;

        END IF;

        UPDATE TELEGRAM_BOT_CONTROL
        SET LAST_UPDATE_ID = V_update_id,
            UPDATED_DATE   = SYSDATE
             WHERE ID = 1;
        COMMIT;

    END LOOP;

EXCEPTION WHEN OTHERS THEN

        DBMS_OUTPUT.PUT_LINE(
            'ERROR: ' || SQLERRM
        );

        ROLLBACK;

        RAISE;

END CHECK_TELEGRAM_MESSAGES;
/