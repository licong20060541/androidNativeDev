//
// Created by Li,Cong(DE) on 2018/9/5.
//


#include "jni_common.h"
#include "com_utils_CUtils.h"

extern "C" {
#include "aes.h"


static uint8_t key[] = {0x2b, 0x7e, 0x15, 0x16, 0x28, 0xae, 0xd2, 0xa6, 0xab, 0xf7, 0x15, 0x88, 0x09, 0xcf, 0x4f, 0x3c};
static uint8_t iv[] = {0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b, 0x0c, 0x0d, 0x0e, 0x0f};


/*
    * Class:     com_utils_CUtils
    * Method:    encode
    * Signature: (Ljava/lang/String;)Ljava/lang/String;
    */
JNIEXPORT jbyteArray JNICALL Java_com_utils_CUtils_encode
        (JNIEnv *jniEnv, jobject object, jstring content) {

    char *encodeContent = NULL;
    encodeContent = (char *) jniEnv->GetStringUTFChars(content, 0);

    LOGD("bird: input: %s ", encodeContent);
    uint32_t myLength = strlen(encodeContent);
    LOGD("bird: input calc length: %d ", myLength);
    myLength = (myLength / 16 + 1) * 16;

    char *buffer = new char[myLength];
    memset(buffer, 0, myLength);

    AES_CBC_encrypt_buffer((uint8_t *) buffer, (uint8_t *) encodeContent, myLength, key, iv);

    jbyteArray jarray = jniEnv->NewByteArray(myLength);
    jniEnv->SetByteArrayRegion(jarray, 0, myLength, (const jbyte *) buffer);

    delete encodeContent;
    delete buffer;
    return jarray;
}


/*
 * Class:     com_utils_CUtils
 * Method:    decode
 * Signature: (Ljava/lang/String;)Ljava/lang/String;
 */
JNIEXPORT jstring JNICALL Java_com_utils_CUtils_decode
        (JNIEnv *jniEnv, jobject object, jbyteArray content) {

    char *olddata = (char *) jniEnv->GetByteArrayElements(content, 0);
    uint32_t oldsize = (uint32_t) jniEnv->GetArrayLength(content);

    char *buffer2 = new char[oldsize];
    memset(buffer2, 0, (size_t) oldsize);

    AES_CBC_decrypt_buffer((uint8_t *) buffer2, (uint8_t *) olddata, oldsize, key, iv);

    LOGD("bird: decode: %s ", buffer2);
    LOGD("bird: decode calc length: %d ", strlen(buffer2));

    jstring tunRes = jniEnv->NewStringUTF(buffer2);

    delete olddata;
    delete buffer2;

    return tunRes;
}




/*
    * Class:     com_utils_CUtils
    * Method:    encode
    * Signature: (Ljava/lang/String;)Ljava/lang/String;
    */
JNIEXPORT jstring JNICALL Java_com_utils_CUtils_encode2(
        JNIEnv *jniEnv, jobject object, jstring content) {

    char *encodeContent = NULL;
    encodeContent = (char *) (u_char *) jniEnv->GetStringUTFChars(content, 0);

    LOGD("bird: input: %s ", encodeContent);
    uint32_t myLength = strlen(encodeContent);
    LOGD("bird: input calc length: %d ", myLength);
    myLength = (myLength / 16 + 1) * 16;

    uint32_t in_count = (uint32_t) myLength;
    char *buffer = (char *) new uint8_t[in_count];
    memset(buffer, 0, in_count);

    AES_CBC_encrypt_buffer((uint8_t *) buffer, (uint8_t *) encodeContent, in_count, key, iv);


    jbyte *by = (jbyte *) buffer;
    jbyteArray jarray = jniEnv->NewByteArray(myLength);
    jniEnv->SetByteArrayRegion(jarray, 0, myLength, by);


    char *olddata = (char *) jniEnv->GetByteArrayElements(jarray, 0);
    uint32_t oldsize = (uint32_t) jniEnv->GetArrayLength(jarray);


    char *buffer2 = (char *) new uint8_t[oldsize];
    memset(buffer2, 0, (size_t) oldsize);

    AES_CBC_decrypt_buffer((uint8_t *) buffer2, (uint8_t *) olddata, oldsize, key, iv);


    LOGD("bird: decode: %s ", buffer2);
    LOGD("bird: decode calc length: %d ", strlen(buffer2));

    jstring tunRes = jniEnv->NewStringUTF((const char *) buffer2);

    delete (encodeContent);
    delete (buffer);
    delete (buffer2);

    return tunRes;
}
}