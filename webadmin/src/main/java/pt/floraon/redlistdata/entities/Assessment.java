package pt.floraon.redlistdata.entities;

import java.util.ArrayList;
import java.util.Collections;
import java.util.List;

/**
 * Created by miguel on 23-11-2016.
 */
public class Assessment {
    private RedListEnums.RedListCategories category;
    private RedListEnums.CRTags subCategory;
    private String criteria;
    private String justification;
    private String[] authors;
    private String collaborators;
    private String[] evaluator;
    private String[] reviewer;
    private RedListEnums.YesNoLikelyUnlikely propaguleImmigration;
    private RedListEnums.YesNoLikelyUnlikely decreaseImmigration;
    private RedListEnums.YesNoLikelyUnlikely isSink;
    private RedListEnums.UpDownList upDownListing;
    private String upDownListingJustification;
    private RedListEnums.TextStatus textStatus;
    private RedListEnums.AssessmentStatus assessmentStatus;
    private RedListEnums.ReviewStatus reviewStatus;
    private RedListEnums.PublicationStatus publicationStatus;
    private List<PreviousAssessment> previousAssessmentList;

    public RedListEnums.YesNoLikelyUnlikely getPropaguleImmigration() {
        return propaguleImmigration;
    }

    public RedListEnums.YesNoLikelyUnlikely getDecreaseImmigration() {
        return decreaseImmigration;
    }

    public RedListEnums.YesNoLikelyUnlikely getIsSink() {
        return isSink;
    }

    public RedListEnums.RedListCategories getCategory() {
        return category;
    }

    public RedListEnums.CRTags getSubCategory() {
        if(category == null) return null;
        return category.isTrigger() ? (subCategory == RedListEnums.CRTags.NO_TAG ? null : subCategory) : null;
    }

    public String getCriteria() {
        return criteria;
    }

    public String getJustification() {
        return justification;
    }

    public RedListEnums.UpDownList getUpDownListing() {
        return upDownListing;
    }

    public String getUpDownListingJustification() {
        return upDownListingJustification;
    }

    public String[] getAuthors() {
        return authors == null ? new String[0] : authors;
    }

    public String getCollaborators() {
        return collaborators;
    }

    public String[] getEvaluator() {
        return evaluator == null ? new String[0] : evaluator;
    }

    public String[] getReviewer() {
        return reviewer == null ? new String[0] : reviewer;
    }

    public RedListEnums.AssessmentStatus getAssessmentStatus() {
        return assessmentStatus;
    }

    public RedListEnums.TextStatus getTextStatus() {
        return textStatus;
    }

    public RedListEnums.ReviewStatus getReviewStatus() {
        return reviewStatus;
    }

    public RedListEnums.PublicationStatus getPublicationStatus() {
        return publicationStatus;
    }

    public List<PreviousAssessment> getPreviousAssessmentList() {
        return this.previousAssessmentList == null ? Collections.EMPTY_LIST : this.previousAssessmentList;
    }


    public void setCategory(RedListEnums.RedListCategories category) {
        this.category = category.getOriginalCategory();
    }

    public void setSubCategory(RedListEnums.CRTags subCategory) {
        this.subCategory = subCategory;
    }

    public void setPropaguleImmigration(RedListEnums.YesNoLikelyUnlikely propaguleImmigration) {
        this.propaguleImmigration = propaguleImmigration;
    }

    public void setDecreaseImmigration(RedListEnums.YesNoLikelyUnlikely decreaseImmigration) {
        this.decreaseImmigration = decreaseImmigration;
    }

    public void setIsSink(RedListEnums.YesNoLikelyUnlikely isSink) {
        this.isSink = isSink;
    }

    public void setCriteria(String criteria) {
        this.criteria = criteria;
    }

    public void setJustification(String justification) {
        this.justification = justification;
    }

    public void setAuthors(String[] authors) {
        this.authors = authors;
    }

    public void setCollaborators(String collaborators) {
        this.collaborators = collaborators;
    }

    public void setEvaluator(String[] evaluator) {
        this.evaluator = evaluator;
    }

    public void setReviewer(String[] reviewer) {
        this.reviewer = reviewer;
    }

    public void setUpDownListing(RedListEnums.UpDownList upDownListing) {
        this.upDownListing = upDownListing;
    }

    public void setUpDownListingJustification(String upDownListingJustification) {
        this.upDownListingJustification = upDownListingJustification;
    }

    public void setAssessmentStatus(RedListEnums.AssessmentStatus assessmentStatus) {
        this.assessmentStatus = assessmentStatus;
    }

    public void setTextStatus(RedListEnums.TextStatus textStatus) {
        this.textStatus = textStatus;
    }

    public void setReviewStatus(RedListEnums.ReviewStatus reviewStatus) {
        this.reviewStatus = reviewStatus;
    }

    public void setPublicationStatus(RedListEnums.PublicationStatus publicationStatus) {
        this.publicationStatus = publicationStatus;
    }

    public void setPreviousAssessmentList(List<PreviousAssessment> previousAssessmentList) {
        this.previousAssessmentList = previousAssessmentList;
    }

    /* *****************************************/
    /* Convenience functions for functionality */
    /* *****************************************/

    /**
     * Suggests uplist or downlist according to the answers to the rescue effect questions
     * @return
     */
    public RedListEnums.UpDownList suggestUpDownList() {
        if(
                this.propaguleImmigration == RedListEnums.YesNoLikelyUnlikely.NOT_KNOWN
                        || this.propaguleImmigration == RedListEnums.YesNoLikelyUnlikely.NO
                        ||  (
                        (this.propaguleImmigration == RedListEnums.YesNoLikelyUnlikely.YES
                                || this.propaguleImmigration == RedListEnums.YesNoLikelyUnlikely.LIKELY)
                                && (this.decreaseImmigration == RedListEnums.YesNoLikelyUnlikely.YES
                                || this.decreaseImmigration == RedListEnums.YesNoLikelyUnlikely.NOT_KNOWN)
                                && (this.isSink == RedListEnums.YesNoLikelyUnlikely.NO
                                || this.isSink == RedListEnums.YesNoLikelyUnlikely.NOT_KNOWN)
                )
                ) return RedListEnums.UpDownList.NONE;

        if(
                (this.propaguleImmigration == RedListEnums.YesNoLikelyUnlikely.YES
                        || this.propaguleImmigration == RedListEnums.YesNoLikelyUnlikely.LIKELY)
                        && (this.decreaseImmigration == RedListEnums.YesNoLikelyUnlikely.NO
                        || this.decreaseImmigration == RedListEnums.YesNoLikelyUnlikely.UNLIKELY)
                ) return RedListEnums.UpDownList.DOWNLIST;

        if(
                (this.propaguleImmigration == RedListEnums.YesNoLikelyUnlikely.YES
                        || this.propaguleImmigration == RedListEnums.YesNoLikelyUnlikely.LIKELY)
                        && (this.decreaseImmigration == RedListEnums.YesNoLikelyUnlikely.YES
                        || this.decreaseImmigration == RedListEnums.YesNoLikelyUnlikely.NOT_KNOWN)
                        && (this.isSink == RedListEnums.YesNoLikelyUnlikely.YES
                        || this.isSink == RedListEnums.YesNoLikelyUnlikely.LIKELY)
                ) return RedListEnums.UpDownList.UPLIST;

        return RedListEnums.UpDownList.NONE;
    }

    /**
     * Gets the category after being adjusted by the uplist/downlist choice
     * @return
     */
    public RedListEnums.RedListCategories getAdjustedCategory() {
        if(category == null) return null;
        if(upDownListing == null) return category;
        switch(upDownListing) {
            case UPLIST: return category.getUplistCategory();
            case DOWNLIST: return category.getDownlistCategory();
            default: return category;
        }
    }

    public void addPreviousAssessment(int year, RedListEnums.RedListCategories category) {
        if(this.previousAssessmentList == null || this.previousAssessmentList.size() == 0)
            this.previousAssessmentList = new ArrayList<PreviousAssessment>();
        this.previousAssessmentList.add(new PreviousAssessment(year, category));
    }

}