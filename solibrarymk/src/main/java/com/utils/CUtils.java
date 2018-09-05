package com.utils;

/**
 * Created by licong12 on 2018/9/3.
 */

public class CUtils {

    public native byte[] encode(String rawText);

    public native String decode(byte[] contents);

}
