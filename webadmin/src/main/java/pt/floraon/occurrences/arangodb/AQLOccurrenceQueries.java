package pt.floraon.occurrences.arangodb;

import java.util.Map;
import java.util.MissingResourceException;
import java.util.ResourceBundle;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 * Created by miguel on 24-03-2017.
 */
public class AQLOccurrenceQueries {
    private static final String BUNDLE_NAME = "pt.floraon.occurrences.aqlqueries";

    private static final ResourceBundle RESOURCE_BUNDLE = ResourceBundle.getBundle(BUNDLE_NAME);

    private static final Pattern substitutionPattern = Pattern.compile("\\{@(\\w+)\\}");

    private AQLOccurrenceQueries() {
    }

    public static String getString(String key) {
        try {
            String msg = RESOURCE_BUNDLE.getString(key);
            // replace named AQL fragments
            Matcher mat = substitutionPattern.matcher(msg);
            while (mat.find()) {
                msg = msg.replace("{@" + mat.group(1) + "}", getString(mat.group(1)));
            }
            return msg;
        } catch (MissingResourceException e) {
            return '!' + key + '!';
        }
    }

    @Deprecated
    public static String getString(String key, Object... params) {
        String msg = RESOURCE_BUNDLE.getString(key);
        // replace named AQL fragments
        Matcher mat = substitutionPattern.matcher(msg);
        while (mat.find()) {
            msg = msg.replace("{@" + mat.group(1) + "}", getString(mat.group(1), params));
        }
        // now substitute passed variables
        try {
            msg = String.format(msg, params);
        } catch (MissingResourceException e) {
            return '!' + key + '!';
        }
        return msg;
    }

    @Deprecated
    public static String getString(String key, Map<String,String> params) {
        String msg;
        try {
            msg = RESOURCE_BUNDLE.getString(key);
        } catch (MissingResourceException e) {
            return '!' + key + '!';
        }
        for(Map.Entry<String,String> p : params.entrySet()) {
            msg = msg.replace(p.getKey(), p.getValue());
        }
        return msg;
    }

}
