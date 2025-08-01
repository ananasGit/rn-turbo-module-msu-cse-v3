package com.rnturbomodulemsucsev3;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import java.util.Arrays;
import java.util.Calendar;
import java.util.List;
import java.util.Locale;

import static com.rnturbomodulemsucsev3.CSETextUtils.isBlank;

/**
 * Created by jasmin.suljic@monri.com
 * MSU CSE
 */
class CardUtils {

    private static final String regVisa = "^4\\d*";
    private static final String regMaster = "^5[1-5]\\d*";
    private static final String regExpress = "^(34|37)\\d*";
    private static final String regDiners = "^((30[0-5])|309|36|38|39)\\d*";
    private static final String regDiscover = "^(6011|65|(6221[2-9][6-9])|(622[2-8][0-9][0-9])|(6229[0-1][0-9])|(62292[0-5])|(64[4-9]))\\d*";
    private static final String regJCB = "^(35[2][8-9]|35[3-8][0-9])\\d*";
    private static final String regTroy = "^9792[00-99]\\d*";
    private static final String regDina = "^9891(0[0-4]|0[6-7]|09|1[1-5]|1[7-9]|2[1-5]|27|29|30|31|35|36|4[0-4]|46|49|5[0-3]|5[5-9]|6[0-1]|6[4-9]|70|7[3-8]|80|8[6-9])\\d*";

    private static final int LENGTH_COMMON_CARD = 16;
    private static final int LENGTH_AMERICAN_EXPRESS = 15;
    private static final int LENGTH_DINERS_CLUB = 14;
    private static final List<Integer> MAESTRO_CARD_LENGTH = Arrays.asList(12, 13, 14, 15, 16, 17, 18, 19);
    private static final List<Integer> VISA_CARD_LENGTH = Arrays.asList(16, 19);

    private static final List<String> PREFIXES_MAESTRO = Arrays.asList("56", "58", "67", "502", "503", "506", "639", "5018", "6020");

    /**
     * @param month
     * @param year
     * @return
     */
    static boolean isValidExpiry(Calendar now, Integer month, Integer year) {
        if (!validateExpMonth(month)) {
            return false;
        }

        if (!validateExpYear(now, year)) {
            return false;
        }

        return !hasMonthPassed(year, month, now);
    }

    static boolean hasMonthPassed(int year, int month, Calendar now) {
        if (hasYearPassed(year, now)) {
            return true;
        }

        // Expires at end of specified month, Calendar month starts at 0
        return normalizeYear(year, now) == now.get(Calendar.YEAR)
                && month < (now.get(Calendar.MONTH) + 1);
    }

    /**
     * Checks whether or not the expMonth is valid.
     *
     * @return {@code true} if valid, {@code false} otherwise.
     */
    static boolean validateExpMonth(Integer expMonth) {
        return expMonth != null && expMonth >= 1 && expMonth <= 12;
    }

    /**
     * Checks whether or not the expYear is valid.
     *
     * @return {@code true} if valid, {@code false} otherwise.
     */
    static boolean validateExpYear(Calendar now, Integer expYear) {
        return expYear != null && !hasYearPassed(expYear, now);
    }

    /**
     * Determines whether or not the input year has already passed.
     *
     * @param year the input year, as a two or four-digit integer
     * @param now, the current time
     * @return {@code true} if the input year has passed the year of the specified current time
     * {@code false} otherwise.
     */
    static boolean hasYearPassed(int year, Calendar now) {
        int normalized = normalizeYear(year, now);
        return normalized < now.get(Calendar.YEAR);
    }

    static int normalizeYear(int year, Calendar now) {
        if (year < 100 && year >= 0) {
            String currentYear = String.valueOf(now.get(Calendar.YEAR));
            String prefix = currentYear.substring(0, currentYear.length() - 2);
            year = Integer.parseInt(String.format(Locale.US, "%s%02d", prefix, year));
        }
        return year;
    }

    /**
     * Checks to see whether the input number is of the correct length, after determining its brand.
     * This function does not perform a Luhn check.
     *
     * @param cardNumber the card number with no spaces or dashes
     * @return {@code true} if the card number is of known type and the correct length
     */
    static boolean isValidCardLength(@Nullable String cardNumber) {
        return cardNumber != null && isValidCardLength(cardNumber,
                getCardBrand(CSETextUtils.removeNonDigits(cardNumber)));
    }

    /**
     * Checks to see whether the input number is of the correct length, given the assumed brand of
     * the card. This function does not perform a Luhn check.
     *
     * @param cardNumber the card number with no spaces or dashes
     * @param cardBrand  a card used to get the correct size
     * @return {@code true} if the card number is the correct length for the assumed brand
     */
    static boolean isValidCardLength(
            @Nullable String cardNumber,
            CardBrand cardBrand) {
        if (cardNumber == null || CardBrand.UNKNOWN.equals(cardBrand)) {
            return false;
        }

        int length = cardNumber.length();
        switch (cardBrand) {
            case AMERICAN_EXPRESS:
                return length == LENGTH_AMERICAN_EXPRESS;
            case DINERS_CLUB:
                return length == LENGTH_DINERS_CLUB;
            case MAESTRO:
                return MAESTRO_CARD_LENGTH.contains(length);
            case VISA:
                return VISA_CARD_LENGTH.contains(length);
            default:
                return length == LENGTH_COMMON_CARD;
        }
    }

    private static CardBrand getPossibleCardBrand(@Nullable String cardNumber) {
        return getPossibleCardBrand(cardNumber, true);
    }

    @NonNull
    static CardBrand getPossibleCardBrand(@Nullable String cardNumber,
                                          boolean shouldNormalize) {
        return getCardBrand(CSETextUtils.removeNonDigits(cardNumber));
    }

    /**
     * Checks the input string to see whether or not it is a valid Luhn number.
     *
     * @param cardNumber a String that may or may not represent a valid Luhn number
     * @return {@code true} if and only if the input value is a valid Luhn number
     */
    static boolean isValidLuhnNumber(@Nullable String cardNumber) {
        if (cardNumber == null) {
            return false;
        }

        boolean isOdd = true;
        int sum = 0;

        for (int index = cardNumber.length() - 1; index >= 0; index--) {
            char c = cardNumber.charAt(index);
            if (!Character.isDigit(c)) {
                return false;
            }

            int digitInteger = Character.getNumericValue(c);
            isOdd = !isOdd;

            if (isOdd) {
                digitInteger *= 2;
            }

            if (digitInteger > 9) {
                digitInteger -= 9;
            }

            sum += digitInteger;
        }

        return sum % 10 == 0;
    }

    static CardBrand getBrand(String number) {
        if (number == null) {
            return null;
        }

        return getCardBrand(CSETextUtils.removeNonDigits(number));
    }

    /**
     * Check to see whether the input string is a whole, positive number.
     *
     * @param value the input string to test
     * @return {@code true} if the input value consists entirely of integers
     */
    static boolean isWholePositiveNumber(@Nullable String value) {
        return value != null && isDigitsOnly(value);
    }

    static boolean isDigitsOnly(String str) {
        if (str.equals("")) {
            return false;
        }
        final int len = str.length();
        for (int i = 0; i < len; i++) {
            if (!Character.isDigit(str.charAt(i))) {
                return false;
            }
        }
        return true;
    }

    static CardBrand getCardBrand(String pan) {
        if (CSETextUtils.isBlank(pan)) {
            return CardBrand.UNKNOWN;
        }
        String bin = CSETextUtils.safeSubstring(pan, 0, 6);

        if (bin.matches(regVisa)) {
            return CardBrand.VISA;
        } else if (startsWithInList(bin, PREFIXES_MAESTRO)) {
            return CardBrand.MAESTRO;
        } else if (bin.matches(regMaster)) {
            return CardBrand.MASTERCARD;
        } else if (bin.matches(regExpress)) {
            return CardBrand.AMERICAN_EXPRESS;
        } else if (bin.matches(regDiners)) {
            return CardBrand.DINERS_CLUB;
        } else if (bin.matches(regDiscover)) {
            return CardBrand.DISCOVER;
        } else if (bin.matches(regJCB)) {
            return CardBrand.JCB;
        } else if (bin.matches(regTroy)) {
            return CardBrand.TROY;
        } else if (bin.matches(regDina)) {
            return CardBrand.DINACARD;
        } else {
            return CardBrand.UNKNOWN;
        }
    }

    private static boolean startsWithInList(String pan, @SuppressWarnings("SameParameterValue") List<String> prefixes) {
        for (String prefix : prefixes) {
            boolean startsWith = pan.startsWith(prefix);
            if (startsWith) {
                return true;
            }
        }

        return false;
    }

    static boolean isValidCardHolderName(String name) {
        return name != null && name.length() > 0 && name.length() <= 128;
    }

    static boolean isValidCVV(String cvv) {
        return isValidCVV(cvv, null);
    }

    static boolean isValidPan(String pan) {
        pan = CSETextUtils.removeNonDigits(pan);
        return CardUtils.isValidLuhnNumber(pan) && CardUtils.isValidCardLength(pan);
    }

    static boolean isValidCardToken(String cardToken) {
        return cardToken != null && cardToken.length() >= 32 && cardToken.length() <= 64;
    }

    static CardBrand detectBrand(String pan) {
        final String digits = CSETextUtils.removeNonDigits(pan);

        if (digits == null) {
            throw new IllegalStateException("First 4 digits of PAN expected");
        }

        return getBrand(digits);
    }

    static boolean isValidCVV(String cvv, String pan) {
        if (isBlank(cvv)) {
            return false;
        }

        String cvcValue = cvv.trim();
        CardBrand brand = getBrand(pan);
        boolean validLength =
                (brand == null && cvcValue.length() >= 3 && cvcValue.length() <= 4)
                        || (CardBrand.AMERICAN_EXPRESS.equals(brand) && cvcValue.length() == 4)
                        || cvcValue.length() == 3;

        return isWholePositiveNumber(cvcValue) && validLength;
    }

    static boolean validateNonce(String nonce) {
        return nonce != null && nonce.length() > 0 && nonce.length() <= 16;
    }
}
