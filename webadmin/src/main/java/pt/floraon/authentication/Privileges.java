package pt.floraon.authentication;

import pt.floraon.redlistdata.entities.RedListEnums;

import java.util.*;

/**
 * Created by miguel on 06-01-2017.
 */
public enum Privileges  implements RedListEnums.LabelledEnum {
    VIEW_FULL_SHEET(PrivilegeType.REDLISTDATA, PrivilegeScope.PER_SPECIES, "View full sheet")
    , VIEW_OCCURRENCES(PrivilegeType.REDLISTDATA, PrivilegeScope.PER_SPECIES, "View occurrences")
    , EXCLUDE_OCCURRENCES(PrivilegeType.REDLISTDATA, PrivilegeScope.PER_SPECIES, "Exclude occurrences")
    , MODIFY_OCCURRENCES(PrivilegeType.REDLISTDATA, PrivilegeScope.PER_SPECIES, "Modify occurrences")
    , DOWNLOAD_OCCURRENCES(PrivilegeType.REDLISTDATA, PrivilegeScope.PER_SPECIES, "Download occurrences")
    , EDIT_SECTION2(PrivilegeType.REDLISTDATA, PrivilegeScope.PER_SPECIES, "Edit section 2")
    , EDIT_SECTION3(PrivilegeType.REDLISTDATA, PrivilegeScope.PER_SPECIES, "Edit section 3")
    , EDIT_SECTION4(PrivilegeType.REDLISTDATA, PrivilegeScope.PER_SPECIES, "Edit section 4")
    , EDIT_SECTION5(PrivilegeType.REDLISTDATA, PrivilegeScope.PER_SPECIES, "Edit section 5")
    , EDIT_SECTION6(PrivilegeType.REDLISTDATA, PrivilegeScope.PER_SPECIES, "Edit section 6")
    , EDIT_SECTION7(PrivilegeType.REDLISTDATA, PrivilegeScope.PER_SPECIES, "Edit section 7")
    , EDIT_SECTION8(PrivilegeType.REDLISTDATA, PrivilegeScope.PER_SPECIES, "Edit section 8")
    , EDIT_SECTION9(PrivilegeType.REDLISTDATA, PrivilegeScope.PER_SPECIES, "Edit section 9")
    , EDIT_ALL_TEXTUAL(PrivilegeType.REDLISTDATA, PrivilegeScope.PER_SPECIES, "Edit all textual")
    , EDIT_ALL_1_8(PrivilegeType.REDLISTDATA, PrivilegeScope.PER_SPECIES, "Edit sections 1-8")
    , EDIT_1_4(PrivilegeType.REDLISTDATA, PrivilegeScope.PER_SPECIES, "Edit 1.4")
    , EDIT_9_1_2_3_4(PrivilegeType.REDLISTDATA, PrivilegeScope.PER_SPECIES, "Edit 9.1 - 9.4")
    , EDIT_9_7_9_92(PrivilegeType.REDLISTDATA, PrivilegeScope.PER_SPECIES, "Edit 9.7, 9.9.2")
    , EDIT_9_8_9_93(PrivilegeType.REDLISTDATA, PrivilegeScope.PER_SPECIES, "Edit 9.8, 9.9.3")
    , EDIT_9_9_4(PrivilegeType.REDLISTDATA, PrivilegeScope.PER_SPECIES, "Edit 9.9.4")
    , EDIT_9_5_9_6_9_61_9_91(PrivilegeType.REDLISTDATA, PrivilegeScope.PER_SPECIES, "Edit 9.5, 9.6, 9.6.1, 9.9.1")
    , EDIT_9_3_9_45(PrivilegeType.REDLISTDATA, PrivilegeScope.PER_SPECIES, "Edit 9.3, 9.4.5")

    , CREATE_REDLIST_DATASETS(PrivilegeType.GLOBAL, PrivilegeScope.GLOBAL, "Create RedList datasets")
    , MODIFY_TAXA_TERRITORIES(PrivilegeType.CHECKLIST, PrivilegeScope.GLOBAL, "Modify taxa and territories")
    , EDIT_FULL_CHECKLIST(PrivilegeType.CHECKLIST, PrivilegeScope.GLOBAL, "Edit full checklist")
    , MANAGE_REDLIST_USERS(PrivilegeType.GLOBAL, PrivilegeScope.GLOBAL, "Manage RedList users");

    public static Privileges[] EDIT_ALL_FIELDS = new Privileges[] { EDIT_SECTION2, EDIT_SECTION3, EDIT_SECTION4
            , EDIT_SECTION5, EDIT_SECTION6, EDIT_SECTION7, EDIT_SECTION8, EDIT_SECTION9, EDIT_ALL_TEXTUAL, EDIT_ALL_1_8
            , EDIT_1_4, EDIT_9_7_9_92, EDIT_9_1_2_3_4, EDIT_9_3_9_45, EDIT_9_5_9_6_9_61_9_91, EDIT_9_8_9_93, EDIT_9_9_4 };

    public static Privileges[] EDIT_SECTIONS2_8 = new Privileges[] { EDIT_SECTION2, EDIT_SECTION3, EDIT_SECTION4
        , EDIT_SECTION5, EDIT_SECTION6, EDIT_SECTION7, EDIT_SECTION8};

    private PrivilegeType privilegeType;
    private PrivilegeScope privilegeScope;
    private String label;

    /**
     * These are the list of privileges that trigger a user to be considered as responsible for:
     * - texts
     * - assessment
     * - revision
     */
    public static Set<String> responsibleTextsPrivileges = new HashSet<>();
    public static Set<String> responsibleAssessmentPrivileges = new HashSet<>();
    public static Set<String> responsibleRevisionPrivileges = new HashSet<>();
    static {
        responsibleTextsPrivileges.add(EDIT_ALL_1_8.toString());
        responsibleTextsPrivileges.add(EDIT_ALL_TEXTUAL.toString());

        responsibleAssessmentPrivileges.add(EDIT_9_1_2_3_4.toString());

        responsibleRevisionPrivileges.add(EDIT_9_3_9_45.toString());
    }

    Privileges(PrivilegeType pt, PrivilegeScope ps, String label) {
        this.privilegeType = pt;
        this.privilegeScope = ps;
        this.label = label;
    }

    public PrivilegeType getPrivilegeType() {
        return this.privilegeType;
    }

    public PrivilegeScope getPrivilegeScope() {
        return this.privilegeScope;
    }

    public enum PrivilegeType {CHECKLIST, REDLISTDATA, GLOBAL}

    public enum PrivilegeScope {PER_SPECIES, GLOBAL}

    public static class PrivilegeNameComparator implements Comparator<Privileges> {
        public int compare(Privileges o1, Privileges o2) {
            return o1.toString().compareTo(o2.toString());
        }
    }

    public static List<Privileges> getAllPrivilegesOfTypeAndScope(PrivilegeType type, PrivilegeScope scope) {
        List<Privileges> out = new ArrayList<>();
        boolean add;
        for (Privileges priv : Privileges.values()) {
            add = true;
            if(type != null) add &= priv.getPrivilegeType() == type;
            if(scope != null) add &= priv.getPrivilegeScope() == scope;
            if(add) out.add(priv);
        }
        Collections.sort(out, new PrivilegeNameComparator());
        return out;
    }

    public static boolean isResponsibleForTexts(List<String> privileges) {
        return !Collections.disjoint(responsibleTextsPrivileges, privileges);
    }

    public static boolean isResponsibleForAssessment(List<String> privileges) {
        return !Collections.disjoint(responsibleAssessmentPrivileges, privileges);
    }

    public static boolean isResponsibleForRevision(List<String> privileges) {
        return !Collections.disjoint(responsibleRevisionPrivileges, privileges);
    }

    @Override
    public String getLabel() {
        return this.label;
    }

}
