class Instructor::AssignmentCritiquesController < Instructor::BaseController
  
  def create
    logger.debug('-----------')
    logger.debug(params[:assignment_submission].to_yaml)
    logger.debug('-----------')
    
    critiques = params[:critique] if params.has_key?(:critique)
    if critiques
      if critiques.has_key?(:assignment)
        critiques[:assignment].each do |id, content|
          @submission_id = id
          if !content[:content].blank? || !content[:attachment].nil? ||  (content[:original] != content[:rearrangement])
            logger.debug("create critique")
            assignment = AssignmentSubmission.find_by_id(id)
            critique = assignment.critiques.new
            #critique.critiqueable_id = id, 
            #critique.critiqueable_type = 'AssignmentSubmission', 
            critique.user = current_user
            critique.comment = content[:content].blank? && !content[:attachment].nil? ? "File attached" : content[:content]
            
            if content[:original] != content[:rearrangement]
              critique.original_sequence = content[:original]
              critique.rearrangement_sequence = content[:rearrangement]
              critique.comment = 'Rearrangement' if critique.comment.blank? 
            end
            
            critique.save!
            if !content[:attachment].nil?
              @attachable = critique
              @attachment = build_attachment({:asset => content[:attachment]})
              @attachment.save!
            end
            critique.save!
          end
          logger.debug("--#{id}--#{content[:content]}--#{content[:content].blank?}")
        end
      end
      if critiques.has_key?(:attachment)
        critiques[:attachment].each do |id, content|
          logger.debug("--#{id}--#{content[:content]}--#{content[:content].blank?}")
          if !content[:content].blank? || !content[:attachment].nil?
            logger.debug("create critique #{id}")
            attachment = Attachment.find_by_id(id)
            critique = attachment.critiques.new
            #critique.critiqueable_type = 'Attachment', 
            #critique.critiqueable_id = id,
            critique.user = current_user
            critique.comment = content[:content].blank? && !content[:attachment].nil? ? "File attached" : content[:content]
            critique.save!
            if !content[:attachment].nil?
              @attachable = critique
              @attachment = build_attachment({:asset => content[:attachment]})
              @attachment.save!
            end
          end
        end
      end
    end
    
    @submission_id.nil? ? redirect_to(instructor_courses_path) : redirect_to(instructor_submission_path(@submission_id, :submitted => true))
  end

end