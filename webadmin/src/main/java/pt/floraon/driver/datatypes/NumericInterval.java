package pt.floraon.driver.datatypes;

import pt.floraon.driver.utils.StringUtils;

import java.io.Serializable;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class NumericInterval implements Serializable {
    protected String text;
    private transient static Pattern intervalMatch =
            Pattern.compile("^\\s*(?<modifier>[<>])? *(?<approx>~)? *(?<n1>-?[0-9]+([.,][0-9]+)?)(?: *- *(?<n2>-?[0-9]+([.,][0-9]+)?))?\\s*$");
    private transient Matcher matcher;
    protected transient Float minValue, maxValue, exactValue;
    protected transient boolean approximateValue = false, parsed = false;
    protected transient String error;

    public NumericInterval(String text) {
        this.text = text;
    }

    @Override
    public String toString() {
        return this.text;
    }

    protected void parseText() {  // lazy parsing
        if(this.parsed) return;
        this.parsed = true;
        if(this.matcher == null) {
            if(StringUtils.isStringEmpty(this.text)) return;
            this.matcher = intervalMatch.matcher(this.text);
            if(!this.matcher.find()) {
                this.error = "Invalid interval: " + this.text;
                return;
            }
            if(this.matcher.group("approx") != null) this.approximateValue = true;

            if(this.matcher.group("n2") == null) {
                if(this.matcher.group("modifier") == null)
                    this.exactValue = Float.parseFloat(this.matcher.group("n1"));
                else {
                    if(this.matcher.group("modifier").equals("<"))
                        this.maxValue = Float.parseFloat(this.matcher.group("n1"));
                    else
                        this.minValue = Float.parseFloat(this.matcher.group("n1"));
                }
            } else {
                if(this.matcher.group("modifier") != null) {
                    this.error = "Invalid interval: " + this.text;
                    return;
                }
                this.minValue = Float.parseFloat(this.matcher.group("n1"));
                this.maxValue = Float.parseFloat(this.matcher.group("n2"));
                if(this.minValue > this.maxValue) {
                    Float tmp = this.minValue;
                    this.minValue = this.maxValue;
                    this.maxValue = tmp;
                }
            }
        }
    }

    public Float getMinValue() {
        parseText();
        if(this.minValue != null)
            return this.minValue;
        else {
            if(this.maxValue != null)
                return null;
            else
                return this.exactValue;
        }
    }

    public Float getMaxValue() {
        parseText();
        if(this.maxValue != null)
            return this.maxValue;
        else {
            if(this.minValue != null)
                return null;
            else
                return this.exactValue;
        }
    }

    public Float getValue() {
        parseText();
        return this.exactValue;
    }

    public boolean isApproximateValue() {
        parseText();
        return this.approximateValue;
    }

    public String getError() {
        parseText();
        return this.error;
    }

    public boolean isEmpty() {
        parseText();
        return this.exactValue == null && this.maxValue == null && this.minValue == null;
    }

    public static NumericInterval emptyInterval() {
        return new NumericInterval("");
    }
}
