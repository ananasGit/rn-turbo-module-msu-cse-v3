package com.rnturbomodulemsucsev3;

import java.util.Arrays;
import java.util.Calendar;
import java.util.List;

/**
 * Card validation utilities
 * Ported from iOS implementation
 */
public class CardUtils {

    // Card lengths
    private static final int LENGTH_COMMON_CARD = 16;
    private static final int LENGTH_AMERICAN_EXPRESS = 15;
    private static final int LENGTH_DINERS_CLUB = 14;
    private static final List<Integer> MAESTRO_CARD_LENGTH = Arrays.asList(12, 13, 14, 15, 16, 17, 18, 19);
    private static final List<Integer> VISA_CARD_LENGTH = Arrays.asList(16, 19);

    // Card brand prefixes
    private static final List<String> PREFIXES_AMERICAN_EXPRESS = Arrays.asList("34", "37");
    private static final List<String> PREFIXES_DISCOVER = Arrays.asList("60", "64", "65");
    private static final List<String> PREFIXES_JCB = Arrays.asList("35");
    private static final List<String> PREFIXES_DINERS_CLUB = Arrays.asList("300", "301", "302", "303", "304", "305", "309", "36", "38", "39");
    private static final List<String> PREFIXES_VISA = Arrays.asList("4");
    private static final List<String> PREFIXES_MASTERCARD = Arrays.asList(
            "2221", "2222", "2223", "2224", "2225", "2226", "2227", "2228", "2229",
            "223", "224", "225", "226", "227", "228", "229",
            "23", "24", "25", "26",
            "270", "271", "2720",
            "50", "51", "52", "53", "54", "55", "67"
    );
    private static final List<String> PREFIXES_UNIONPAY = Arrays.asList("62");
    private static final List<String> PREFIXES_MAESTRO = Arrays.asList("56", "58", "67", "502", "503", "506", "639", "5018", "6020");
    
    // Troy prefixes (979200-979299)
    private static final List<String> PREFIXES_TROY = Arrays.asList(
            "979200", "979201", "979202", "979203", "979204", "979205", "979206", "979207", "979208", "979209",
            "979210", "979211", "979212", "979213", "979214", "979215", "979216", "979217", "979218", "979219",
            "979220", "979221", "979222", "979223", "979224", "979225", "979226", "979227", "979228", "979229",
            "979230", "979231", "979232", "979233", "979234", "979235", "979236", "979237", "979238", "979239",
            "979240", "979241", "979242", "979243", "979244", "979245", "979246", "979247", "979248", "979249",
            "979250", "979251", "979252", "979253", "979254", "979255", "979256", "979257", "979258", "979259",
            "979260", "979261", "979262", "979263", "979264", "979265", "979266", "979267", "979268", "979269",
            "979270", "979271", "979272", "979273", "979274", "979275", "979276", "979277", "979278", "979279",
            "979280", "979281", "979282", "979283", "979284", "979285", "979286", "979287", "979288", "979289",
            "979290", "979291", "979292", "979293", "979294", "979295", "979296", "979297", "979298", "979299"
    );
    
    // Dinacard prefixes
    private static final List<String> PREFIXES_DINACARD = Arrays.asList(
            "9891",
            "655670", "655671", "655672", "655673", "655674", "655675", "655676", "655677", "655678", "655679",
            "655680", "655681", "655682", "655683", "655684", "655685", "655686", "655687", "655688", "655689",
            "655690", "655691", "655692", "655693", "655694", "655695", "655696", "655697",
            "657371", "657372", "657373", "657374", "657375", "657376", "657377", "657378", "657379", "657380",
            "657381", "657382", "657383", "657384", "657385", "657386", "657387", "657388", "657389", "657390",
            "657391", "657392", "657393", "657394", "657395", "657396", "657397", "657398"
    );

    /**
     * Validates PAN using Luhn algorithm and card length
     */
    public static boolean isValidPan(String pan) {
        String panDigits = digitsOnly(pan);
        return luhnCheck(panDigits) && isValidCardLength(panDigits);
    }

    /**
     * Validates CVV based on card brand
     */
    public static boolean isValidCVV(String cvv, String pan) {
        if (cvv == null || cvv.length() == 0) return false;
        
        String cvvDigits = digitsOnly(cvv);
        String cardBrand = detectCardBrand(pan);
        
        if ("unknown".equals(cardBrand) && cvvDigits.length() >= 3 && cvvDigits.length() <= 4) {
            return true;
        }
        if ("american-express".equals(cardBrand) && cvvDigits.length() == 4) {
            return true;
        }
        return cvvDigits.length() == 3;
    }

    /**
     * Validates expiry date
     */
    public static boolean isValidExpiry(int month, int year) {
        if (month < 1 || month > 12) return false;
        
        Calendar now = Calendar.getInstance();
        int normalizedYear = normalizeYear(year);
        int currentYear = now.get(Calendar.YEAR);
        int currentMonth = now.get(Calendar.MONTH) + 1; // Calendar.MONTH is 0-based
        
        if (normalizedYear < currentYear) return false;
        if (normalizedYear == currentYear && month < currentMonth) return false;
        
        return true;
    }

    /**
     * Detects card brand from PAN
     */
    public static String detectCardBrand(String pan) {
        if (pan == null) return "unknown";
        
        String panDigits = digitsOnly(pan);
        
        if (hasAnyPrefix(panDigits, PREFIXES_AMERICAN_EXPRESS)) {
            return "american-express";
        }
        if (hasAnyPrefix(panDigits, PREFIXES_DINACARD)) {
            return "dinacard";
        }
        if (hasAnyPrefix(panDigits, PREFIXES_DISCOVER)) {
            return "discover";
        }
        if (hasAnyPrefix(panDigits, PREFIXES_JCB)) {
            return "jcb";
        }
        if (hasAnyPrefix(panDigits, PREFIXES_DINERS_CLUB)) {
            return "diners-club";
        }
        if (hasAnyPrefix(panDigits, PREFIXES_VISA)) {
            return "visa";
        }
        if (hasAnyPrefix(panDigits, PREFIXES_MAESTRO)) {
            return "maestro";
        }
        if (hasAnyPrefix(panDigits, PREFIXES_MASTERCARD)) {
            return "mastercard";
        }
        if (hasAnyPrefix(panDigits, PREFIXES_UNIONPAY)) {
            return "union-pay";
        }
        if (hasAnyPrefix(panDigits, PREFIXES_TROY)) {
            return "troy";
        }
        
        return "unknown";
    }

    /**
     * Extracts only digits from string
     */
    public static String digitsOnly(String input) {
        if (input == null) return "";
        return input.replaceAll("[^\\d]", "");
    }

    /**
     * Luhn algorithm implementation
     */
    private static boolean luhnCheck(String number) {
        if (number == null || number.length() == 0) return false;
        
        int sum = 0;
        boolean alternate = false;
        
        for (int i = number.length() - 1; i >= 0; i--) {
            int digit = Character.getNumericValue(number.charAt(i));
            
            if (alternate) {
                digit *= 2;
                if (digit > 9) {
                    digit = (digit % 10) + 1;
                }
            }
            
            sum += digit;
            alternate = !alternate;
        }
        
        return (sum % 10) == 0;
    }

    /**
     * Validates card length based on brand
     */
    private static boolean isValidCardLength(String pan) {
        String cardBrand = detectCardBrand(pan);
        int length = pan.length();
        
        switch (cardBrand) {
            case "american-express":
                return length == LENGTH_AMERICAN_EXPRESS;
            case "diners-club":
                return length == LENGTH_DINERS_CLUB;
            case "visa":
                return VISA_CARD_LENGTH.contains(length);
            case "maestro":
                return MAESTRO_CARD_LENGTH.contains(length);
            case "unknown":
                return false;
            default:
                return length == LENGTH_COMMON_CARD;
        }
    }

    /**
     * Checks if number starts with any of the given prefixes
     */
    private static boolean hasAnyPrefix(String number, List<String> prefixes) {
        if (number == null || prefixes == null) return false;
        
        for (String prefix : prefixes) {
            if (number.startsWith(prefix)) {
                return true;
            }
        }
        return false;
    }

    /**
     * Normalizes 2-digit year to 4-digit year
     */
    private static int normalizeYear(int year) {
        if (year >= 0 && year < 100) {
            Calendar now = Calendar.getInstance();
            int currentYear = now.get(Calendar.YEAR);
            int century = (currentYear / 100) * 100;
            return century + year;
        }
        return year;
    }
}