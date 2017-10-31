<?php
ob_start();
App::uses('AppController', 'Controller');
/**
 * Static content controller
 *
 * Override this controller by placing a copy in controllers directory of an application
 *
 * @package       app.Controller
 * @link http://book.cakephp.org/2.0/en/controllers/pages-controller.html
 */
class WebserviceController extends AppController 
{	
	var $components = array('Email', 'RequestHandler', 'Cookie','Image');
	function beforeFilter()
	{
		parent::beforeFilter();
		$this->Auth->allow(array('socialuser','contactUs','outletDetails','getOutletAnalytics','updateStore','addStore','getPlan','sendInvoice','editCompany','companyDetails','getStoreList','addNewCompany','getCompanyList','owner_registration','contactus','getPages','outletexist','phoneClick','deleteReview','getCityLandmark','emailVerification_','getStateCityLandmark','emailVerification','forgotPassword','statesRating','outletNameSearch','reviewList','locationSearch','getReviewOutlet','writeReview','getOutletBookmark','bookmarklike','edit_profile','likes','likescount','outletdetail','bookmarkedoutlet','search', 'registration','login','getcat_subCat','getAccount','getAllSubCat','all_like_unlike','storedetail','storedetail2','storedetail3','all_rating_review','dealdetail','user_profile'));
		$this->layout = null;
		date_default_timezone_set('Asia/Dubai');
		Configure::write('debug',2);
	}

	function socialuser()
	{
		$this->loadModel('User');
		$res_arr = $result = array();		
		if(!empty($this->request->data))
		{
			$user_info = $this->request->data;
			
			if($user_info['type'] == 'f')
			{
				$check = $this->User->find('first', array('conditions' => array('facebook_id' => $user_info['id'])));
			}
			else if($user_info['type'] == 'g')
			{
				$check = $this->User->find('first', array('conditions' => array('google_id' => $user_info['id'])));
			}
			if(count($check) > 0)
			{
				$res_arr['status'] = 1;
				$res_arr['msg'] = 'user exists';
				$user = $check['User'];
				$res_arr['result']['user_id'] = $user['id'];
				$res_arr['result']['email']   = $user['email'];
				$res_arr['result']['first_name']    = $user['first_name'];
				$res_arr['result']['last_name']    = $user['last_name'];
				$res_arr['result']['address'] = $user['address'];
				$res_arr['result']['username']    = $user['username'];				
				$res_arr['result']['profile_img'] = (!empty($user['profile_img']))? SITE_URL.UPLOAD_USERS_DIR.$user['profile_img'] : 1;
				$res_arr['result']['phone_no']= $user['phone_no'];
				$res_arr['result']['dob']     = $user['dob'];						
				
			}else{
				$res_arr['status'] = 0;
				$res_arr['msg'] = 'user does not exists';
			}
			echo json_encode($res_arr);
			exit;	
		}
			die;
	}

    function getOutletAnalytics()
    {
    	$this->loadModel('Outlet');
    	$data = $this->request->data;
    	if(isset($data['outlet_id']) && $data['outlet_id'] != null)
    	{
    		$id   = $data['outlet_id'];
    		$type = (isset($data['type']) ? $data['type'] : 'all');
			
			$this->Session->write('st_search', array('id' => $id));	
			$cond_arr = array('Outlet.id' => $id);
			$joins = array(	
					array(
						'table' => 'outlet_names', 
						'alias' => 'Name',
						'type' => 'left',
						'conditions' => array('Name.id = Outlet.outlet_name_id')
					)
				);
			$this->paginate = array(
				'fields' => array('Outlet.title', 'Name.title as outlet_name'),
				'conditions' => $cond_arr, //array of conditions
				'joins' => $joins			
			);
			$result_arr = $this->paginate('Outlet');
			if($result_arr)
			{
				$this->loadModel('Like');
				$this->loadModel('Review');			
				$this->loadModel('Analytic');
				$timeCondition = array();
				if(isset($data['to']) && isset($data['from']) && $data['to'] != '' && $data['from'] != '')
				{			
					$timeCondition = array('date(created) <'  => $data['to'], 'date(created) >' => $data['from']);
				}	
				$click   	   = $this->Analytic->find('count', array('conditions' => array('ref_id' => $id, 'type' => 'phone_click',$timeCondition)));
				$view    	   = $this->Analytic->find('count', array('conditions' => array('ref_id' => $id, 'type' => 'views',$timeCondition)));
				$clickiPhone   = $this->Analytic->find('count', array('conditions' => array('ref_id' => $id, 'type' => 'phone_click','device_type' => 1,$timeCondition)));
				$viewiPhone    = $this->Analytic->find('count', array('conditions' => array('ref_id' => $id, 'type' => 'views','device_type' => 1,$timeCondition)));
				$clickAndroid  = $this->Analytic->find('count', array('conditions' => array('ref_id' => $id, 'type' => 'phone_click','device_type' => 2,$timeCondition)));
				$viewAndroid   = $this->Analytic->find('count', array('conditions' => array('ref_id' => $id, 'type' => 'views','device_type' => 2,$timeCondition)));
				
				
				$review   = $this->Review->find('count', array('conditions' => array('Review.ref_id' => $id, 'Review.type' => 'outlet', 'Review.status' => 1, 'Review.review !=' => '',$timeCondition)));
				$likes    = $this->Like->find('count',array('conditions'=>array('Like.type' => 'like', 'Like.ref_id'=>$id,'Like.ref_type'=>1,$timeCondition)));
				$bookmark = $this->Like->find('count',array('conditions'=>array('Like.type' => 'bookmark', 'Like.ref_id'=>$id,'Like.ref_type'=>1,$timeCondition)));
				
				$reviewiPhone   = $this->Review->find('count', array('conditions' => array('Review.ref_id' => $id, 'Review.type' => 'outlet', 'Review.status' => 1, 'Review.review !=' => '', 'Review.device_type' => 1,$timeCondition)));
				$reviewAndroid  = $this->Review->find('count', array('conditions' => array('Review.ref_id' => $id, 'Review.type' => 'outlet', 'Review.status' => 1, 'Review.review !=' => '', 'Review.device_type' => 2,$timeCondition)));
				$likesiPhone    = $this->Like->find('count',array('conditions'=>array('Like.type' => 'like', 'Like.ref_id'=>$id,'Like.ref_type'=>1,'Like.device_type' => 1,$timeCondition)));
				$likesAndroid   = $this->Like->find('count',array('conditions'=>array('Like.type' => 'like', 'Like.ref_id'=>$id,'Like.ref_type'=>1,'Like.device_type' => 2,$timeCondition)));
				$bookmarkiPhone = $this->Like->find('count',array('conditions'=>array('Like.type' => 'bookmark', 'Like.ref_id'=>$id,'Like.ref_type'=>1,'Like.device_type' => 1,$timeCondition)));
				$bookmarkAndroid = $this->Like->find('count',array('conditions'=>array('Like.type' => 'bookmark', 'Like.ref_id'=>$id,'Like.ref_type'=>1,'Like.device_type' => 2,$timeCondition)));
				if($type == 'all')
				{
					$arr = array(
									array('name' => 'Bookmark', 'value' => $bookmark+$bookmarkiPhone+$bookmarkAndroid),
									array('name' => 'Click', 'value' => $click+$clickiPhone+$clickAndroid),
									array('name' => 'Likes', 'value' => $likes+$likesiPhone+$likesAndroid),
									array('name' => 'Review', 'value' => $review+$reviewiPhone+$reviewAndroid),
									array('name' => 'View', 'value' => $view+$viewiPhone+$viewAndroid),
								);
				}
				else if($type == 'iphone')
				{
					$arr = array(
									array('name' => 'Bookmark', 'value' => $bookmarkiPhone),
									array('name' => 'Click', 'value' => $clickiPhone),
									array('name' => 'Likes', 'value' => $likesiPhone),
									array('name' => 'Review', 'value' => $reviewiPhone),
									array('name' => 'View', 'value' => $viewiPhone),									
								);
				}
				else if($type == 'android')
				{
					$arr = array(
									array('name' => 'Bookmark', 'value' => $bookmarkAndroid),
									array('name' => 'Click', 'value' => $clickAndroid),
									array('name' => 'Likes', 'value' => $likesAndroid),
									array('name' => 'Review', 'value' => $reviewAndroid),
									array('name' => 'View', 'value' => $viewAndroid),
								);	
					
				}
				else if($type == 'web')
				{
					$arr = array( 
									array('name' => 'Bookmark', 'value' => $bookmark),
									array('name' => 'Click', 'value' => $click),
									array('name' => 'Likes', 'value' => $likes),
									array('name' => 'Review', 'value' => $review),
									array('name' => 'View', 'value' => $view)
								);
					
				}
				$arr = array('status' => 1,'result' => $arr);
			}
			else
			{
				$arr['status'] = 0;		
    			$arr['msg'] = "Outlet doesn't exists.";	
			}	
    	}
    	else
    	{
    		$arr['status'] = 0;		
    		$arr['msg'] = 'Please provide outlet id.';	
    	}	
    				
		echo json_encode($arr);
        die;
    }   

    function addStore()
    {
    	$this->loadModel('Filerec');
		$this->loadModel('City');
		$this->loadModel('Outlet');
		$this->loadModel('Landmark');
		$this->loadModel('OutletName');
		$this->loadModel('Category');
		$this->loadModel('OutletType');			
		$errors = array();
		$add_errors = array();
		$error_flag = false;
		$res_arr = array();
    	if(!empty($this->request->data))
		{			
				$data_arr['Outlet'] = $this->request->data;
				$data_arr['Outlet']['address'] = '';
				$this->Outlet->set($data_arr);

				if(!$this->Outlet->validates())
				{
					$errors = $this->Outlet->validationErrors;
					$error_flag = true;
				}				
				if(!$error_flag)
				{
					//UPLOADING BANNER IMAGE
					if(!empty($_FILES['banner']['name']))
					{
						$config['upload_path'] = UPLOAD_OUTLET_DIR;
						$config['allowed_types'] = 'gif|jpg|png|jpeg';
						$config['max_size']	= 2100;
						$config['encrypt_name'] = true;
						$config['is_image'] = 1;
						
						$this->Upload->initializes($config);
						$d = @getimagesize($_FILES['banner']['tmp_name']);						
						$width = $d[0];
						$height = $d[1];
						if($width < 1200 || $height < 400)
						{
							$error_flag = true;
							$add_errors[] = 'Banner minimum width and height should be greater than 1200x400.';
						}
						if(!$error_flag)
						{
							if ($this->Upload->do_upload('banner'))
							{
								$imgdata_arr = $this->Upload->data();
								$data_arr['Outlet']['banner'] = $imgdata_arr['file_name'];
							}
							else
							{
								$errors[] = "Banner image: ".$this->Upload->display_errors();
								$error_flag = true;
							}
						}	
					}
				}
				
				if(!$error_flag)
				{
					//UPLOADING IMAGE
					$arr_img_ids = array();
					$data_arr_files = array();

					for($x = 0; $x <4; $x++)
					{
						if(!empty($_FILES[$x]['name']))
						{
							$config['upload_path'] = UPLOAD_TEMP_DIR;
							$config['allowed_types'] = 'gif|jpg|png|jpeg';
							$config['max_size']	= 5200;
							$config['encrypt_name'] = true;

							$this->Upload->initializes($config);

							if ($this->Upload->do_upload($x))
							{
								$imgdata_arr = $this->Upload->data();
								$data_arr_files[$x] = $imgdata_arr['file_name'];
							}
							else
							{
								$add_errors[] = $this->Upload->display_errors();
								$error_flag = true;
								break;
							}
						}
						
						if($error_flag)
						{
							break;
						}
					}
				}
				
				$errors = array_merge($errors, $add_errors);
						
				if(!$error_flag)
				{
					$data_arr['Outlet']['slug'] = $this->Outlet->generate_slug($data_arr['Outlet']['title']);
					
					//FOR SAT-THU				

					$data_arr['Outlet']['status'] = 0;
					$subcat = explode(',', $data_arr['Outlet']['subcategory']);
					foreach ($subcat as $k => $v) {
						$data_arr['Category']['Category'][$k] = $v;
					}
					
					$this->Outlet->save($data_arr);
					$id = $this->Outlet->id;
					
					//MAKING THE DIRECTORY WITH ID NAME IF IT DOES NOT EXIST
					$updir = UPLOAD_OUTLET_DIR;
					
					//TO SAVE IMAGES
					if(!empty($data_arr_files))
					{
						foreach($data_arr_files as $filename)
						{
							@rename(UPLOAD_TEMP_DIR.$filename, UPLOAD_OUTLET_DIR.$filename);							
							unset($data_arr_files);
							$data_arr_files['Filerec']['ref_id'] = $id;
							$data_arr_files['Filerec']['ref_type'] = '1';
							$data_arr_files['Filerec']['file_name'] = $filename;
							$this->Filerec->create();
							$this->Filerec->save($data_arr_files);

							$this->create_all_thumbs($filename, UPLOAD_OUTLET_DIR, 'Filerec', 'file_name', '', 'outlet');
						}
					}
					$res_arr = array('msg' => 'Store added successfully','status' => 1);
				}
				else
				{
					$res_arr = array('msg' => $errors,'status' => 0);					
				}				
		}
		else
		{
			
			$res_arr = array('msg' => 'invalid request','status' => 0);					
		}
		echo json_encode($res_arr);
			die;

	}

	function updateStore()
    {
    	$this->loadModel('Filerec');
		$this->loadModel('City');
		$this->loadModel('Outlet');
		$this->loadModel('Landmark');
		$this->loadModel('OutletName');
		$this->loadModel('Category');
		$this->loadModel('OutletType');			
		$errors = array();
		$add_errors = array();
		$error_flag = false;
		$res_arr = array();
    	if(!empty($this->request->data))
		{			
				$data_arr['Outlet'] = $this->request->data;
				$data_arr['Outlet']['address'] = '';
				$this->Outlet->set($data_arr);

				if(!$this->Outlet->validates())
				{
					$errors = $this->Outlet->validationErrors;
					$error_flag = true;
				}				
				if(!$error_flag)
				{
					//UPLOADING BANNER IMAGE
					if(!empty($_FILES['banner']['name']))
					{
						$config['upload_path'] = UPLOAD_OUTLET_DIR;
						$config['allowed_types'] = 'gif|jpg|png|jpeg';
						$config['max_size']	= 2100;
						$config['encrypt_name'] = true;
						$config['is_image'] = 1;
						
						$this->Upload->initializes($config);
						$d = @getimagesize($_FILES['banner']['tmp_name']);						
						$width = $d[0];
						$height = $d[1];
						if($width < 1200 || $height < 400)
						{
							$error_flag = true;
							$add_errors[] = 'Banner minimum width and height should be greater than 1200x400.';
						}
						if(!$error_flag)
						{
							if ($this->Upload->do_upload('banner'))
							{
								$imgdata_arr = $this->Upload->data();
								$data_arr['Outlet']['banner'] = $imgdata_arr['file_name'];
							}
							else
							{
								$errors[] = "Banner image: ".$this->Upload->display_errors();
								$error_flag = true;
							}
						}	
					}
				}
				
				if(!$error_flag)
				{
					//UPLOADING IMAGE
					$arr_img_ids = array();
					$data_arr_files = array();

					for($x = 0; $x <4; $x++)
					{
						if(!empty($_FILES[$x]['name']))
						{
							$config['upload_path'] = UPLOAD_TEMP_DIR;
							$config['allowed_types'] = 'gif|jpg|png|jpeg';
							$config['max_size']	= 5200;
							$config['encrypt_name'] = true;

							$this->Upload->initializes($config);

							if ($this->Upload->do_upload($x))
							{
								$imgdata_arr = $this->Upload->data();
								$data_arr_files[$x] = $imgdata_arr['file_name'];
							}
							else
							{
								$add_errors[] = $this->Upload->display_errors();
								$error_flag = true;
								break;
							}
						}
						
						if($error_flag)
						{
							break;
						}
					}
				}
				
				$errors = array_merge($errors, $add_errors);
						
				if(!$error_flag)
				{
					$data_arr['Outlet']['slug'] = $this->Outlet->generate_slug($data_arr['Outlet']['title']);
					
					//FOR SAT-THU				

					$data_arr['Outlet']['status'] = 0;
					$subcat = explode(',', $data_arr['Outlet']['subcategory']);
					foreach ($subcat as $k => $v) {
						$data_arr['Category']['Category'][$k] = $v;
					}
					$this->Outlet->id = $data_arr['Outlet']['id'];
					$this->Outlet->save($data_arr);
					$id = $this->Outlet->id;
					
					//MAKING THE DIRECTORY WITH ID NAME IF IT DOES NOT EXIST
					$updir = UPLOAD_OUTLET_DIR;
					
					//TO SAVE IMAGES
					if(!empty($data_arr_files))
					{
						foreach($data_arr_files as $filename)
						{
							@rename(UPLOAD_TEMP_DIR.$filename, UPLOAD_OUTLET_DIR.$filename);							
							unset($data_arr_files);
							$data_arr_files['Filerec']['ref_id'] = $id;
							$data_arr_files['Filerec']['ref_type'] = '1';
							$data_arr_files['Filerec']['file_name'] = $filename;
							$this->Filerec->create();
							$this->Filerec->save($data_arr_files);

							$this->create_all_thumbs($filename, UPLOAD_OUTLET_DIR, 'Filerec', 'file_name', '', 'outlet');
						}
					}
					$res_arr = array('msg' => 'Store added successfully','status' => 1);
				}
				else
				{
					$res_arr = array('msg' => $errors,'status' => 0);					
				}				
		}
		else
		{
			
			$res_arr = array('msg' => 'invalid request','status' => 0);					
		}
		echo json_encode($res_arr);
			die;

	}

	function contactus()
    {
		$this->loadModel('ContactUs');			
		$this->ContactUs->save($this->request->data, array('validate' => false));
		$arr['status'] = 1;
		$arr['msg'] = 'Thank you for contacting us';			
		echo json_encode($arr);
        die;
	}
		
        function outletexist() {
            $this->loadModel('OutletName');
            $arr = $result = array();
            if(!empty($this->request->data)) {
                $user_info = $this->request->data;
                $rows = $this->OutletName->find('all', array('conditions' => array('OR' => array('OutletName.email' => $user_info['email'], 'OutletName.licence_no'=>$user_info['licence_no']))));                
                
                if(!empty($rows)) {
                    foreach($rows as $row) {
                        $row = $row['OutletName'];
                        if($row['email']==$user_info['email'] && $row['licence_no']==$user_info['licence_no']) {
                            $arr['status'] = 1;
                            $arr['msg'] = 'Outlet exist.';
                        } else if($row['email']==$user_info['email'] && $row['licence_no']!=$user_info['licence_no']){
                            $arr['status'] = 2;
                            $arr['msg'] = 'Licence Number doesn\'t exist..';
                        } else if($row['email']!=$user_info['email'] && $row['licence_no']==$user_info['licence_no']){
                            $arr['status'] = 3;
                            $arr['msg'] = 'Email doesn\'t exist.';
                        }
                    }
                }else {
                    $arr['status'] = 0;
                    $arr['msg'] = 'Email and Licence Number both doesn\'t exist.';
                }
                
            }
            echo json_encode($arr);
            die;
        }	
	function owner_registration()
	{
		$this->loadModel('User');
		$res_arr = $result = array();		
		if(!empty($this->request->data))
		{
			$user_info = $this->request->data;
			$checkuser = $this->User->find('count', array('conditions' => array('email' => $user_info['email'])));
			if(!$checkuser){
				if (!empty($_FILES['profileImage']['name'])) {
					$user_info['profileImage'] = $_FILES['profileImage'];							
				}			
				if(isset($user_info['profileImage']) && !empty($user_info['profileImage']))
				{
					$name = explode('.',$user_info['profileImage']['name']);						
					$extention = end($name);
					if ($extention == 'png' || $extention == 'jpg' || $extention == 'jpeg' || $extention == 'bmp' || $extention == 'gif' ) {
						$imageName = time().'.'.$extention;                                                        
						$moveFile = WWW_ROOT.'uploads/users/'.$imageName ;
						if(move_uploaded_file($user_info['profileImage']['tmp_name'], $moveFile)) {
							$data['User']['profile_img'] = $imageName;	
						}
					}						
				}			
				$data['User']['first_name']   = $user_info['contact_person'];
				$data['User']['company_name'] = $data['User']['display_name'] = $user_info['company_name'];
				$data['User']['email']        = $user_info['email'];					
				$data['User']['password']     = $user_info['password'];
				$data['User']['device_type']  = $user_info['deviceType'];
				$data['User']['device_id']    = $user_info['deviceId'];
				$data['User']['app_version']  = $user_info['appVersion'];
				$data['User']['phone_no']    =  $user_info['phone_no'];
				$data['User']['user_type']    = 3;
				$data['User']['status']       = 2;
				$data['User']['register_using'] = 1;
				$ver_code = $this->Auth->password(uniqid());				
				$data['User']['verification_code'] = $ver_code;
				$slug = $this->User->generate_user_slug($user_info['contact_person'].'-'. $user_info['contact_person']);
				$data['User']['slug'] = $slug;
									
				if($this->User->save($data, array('validate' => false)))
				{
					
					$this->loadModel('EmailTemplate');
					$ver_link = SITE_URL.'user/verification/'.$ver_code;
					$srch_array = array("{{username}}" => ucwords($data['User']['display_name']), "{{activationlink}}" => $ver_link);
					$email_values = $this->EmailTemplate->getvalues('user_registration', $srch_array);

					$this->Email->from = $email_values['from_name'].' <'.$email_values['from_emailid'].'>';
					$this->Email->to = $data['User']['email'];
					$this->Email->subject = $email_values['subject'];
					$this->Email->sendAs = 'html';
					$this->Email->smtpOptions = Configure::read('EMAIL_CONFIG');
					$this->Email->delivery = EMAIL_DELIVERY;
					$this->Email->send($email_values['content']);

					$this->loadModel('OutletName');
					$data_arr['OutletName']['user_id'] =  $id = $this->User->getLastInsertID();
					$data_arr['OutletName']['email'] = $user_info['email'];					
					$data_arr['OutletName']['title'] = $user_info['company_name'];
					$data_arr['OutletName']['contact_person'] = $user_info['contact_person'];									
					$data_arr['OutletName']['personal_no'] = $user_info['phone_no'];
					$this->OutletName->save($data_arr);	
					
					$this->loadModel('Userinfo');
					$this->loadModel('Usersetting');				
					$data_arr['Userinfo']['user_id'] = $id;
					$this->Userinfo->save($data_arr);
					$this->Usersetting->save(array('Usersetting' => array('user_id' => $id)));

					$res_arr['msg'] =  'Store owner has been registered successfully.Please verify your email.';
					$res_arr['status'] = 1;
				}
			}
			else
			{
				$res_arr['msg'] =  'User already registered';
				$res_arr['status'] = 0;
			}
		}
		echo json_encode($res_arr);
		exit;
	}
	
	function getPlan()
	{
		$this->loadModel('Setting');
		$result = $this->Setting->find('all', array('fields' => array('val', 'key'), 'conditions' => array('Setting.key' => 'outlet_plan_pricing')));
			$final_arr = array();
			foreach($result as $row)
			{
				$final_arr['Setting'] = unserialize($row['Setting']['val']);
			}			
			$res_arr = array('status'=> 1, 
					'price' => array(
										'1' => $final_arr['Setting']['platinum'][1],
										'3' => $final_arr['Setting']['platinum'][3],
										'6' => $final_arr['Setting']['platinum'][6],
										'12' => $final_arr['Setting']['platinum'][12],
									));
			
			echo json_encode($res_arr);
		exit;
	}
	
	function sendInvoice()
	{
		$res_arr = array();	
		
		if(!empty($this->request->data))
		{
			 $user_info = $this->request->data;	
			 if(isset($_FILES['pdffile']) && !empty($_FILES['pdffile']))
			{
				$name = explode('.',$_FILES['pdffile']['name']);						
				$extention = end($name);				
				$imageName = time().'.'.$extention;                                                        
				$moveFile = WWW_ROOT.'uploads/users/'.$imageName ;
				if(move_uploaded_file($_FILES['pdffile']['tmp_name'], $moveFile)) {
						$email = new CakeEmail();
						$email->template('invoice');
						$email->attachments(array('Invoice.pdf' => $moveFile));
						$email->emailFormat('html');
						$email->subject(__('Invoice form Aasaan'));
						$email->viewVars(array('email' => $user_info['email']));
						$email->to($user_info['email']);
						$email->from('info@aasaan.com');
						$email->send();	
						$res_arr = array('status' => 1, 'msg' => 'Email has been sent successfully');
				}										
			}
			else
			{
				$res_arr = array('status' => 0, 'msg' => 'Please attach pdf file');
			}
		}
		else
		{
			$res_arr = array('status' => 0, 'msg' => 'Something went wrong');
		}
		echo json_encode($res_arr);
		exit;
	}
	
	function registration()
	{	
		Configure::write('debug',2);
		/* echo 'aaaa'; print_r($this->request->data); print_r($_FILES);  print_r($_POST);echo 'aaaa'; die;*/ 
		$this->loadModel('User');
		$res_arr = $result = array();		
		if(!empty($this->request->data))
		{		
			$user_info = $this->request->data;
			$fbregister_user_email = $this->User->find('first', array('conditions' => array('email' => $user_info['email'])));
			
			if (!empty($_FILES['profileImage']['name'])) {
				$user_info['profileImage'] = $_FILES['profileImage'];							
			}			
			if(isset($user_info['profileImage']) && !empty($user_info['profileImage']))
			{
				$name = explode('.',$user_info['profileImage']['name']);						
				$extention = end($name);
				if ($extention == 'png' || $extention == 'jpg' || $extention == 'jpeg' || $extention == 'bmp' || $extention == 'gif' ) {
					$imageName = time().'.'.$extention;                                                        
					$moveFile = WWW_ROOT.'uploads/users/'.$imageName ;
					if(move_uploaded_file($user_info['profileImage']['tmp_name'], $moveFile)) {
						$data['User']['profile_img'] = $imageName;	
					}
				}						
			}  
			
			if(isset($user_info['FbId']) && !empty($user_info['FbId']))
			{
				$fbregister_user = $this->User->find('first', array('conditions' => array('facebook_id' => $user_info['FbId'])));
				if (empty($fbregister_user_email) && empty($fbregister_user) && !isset($user_info['Pass']))
				{
					$data['User']['facebook_id'] = $user_info['FbId'];
					$data['User']['display_name'] = $user_info['name'];
					$data['User']['first_name'] = $user_info['name'];
					$data['User']['email'] = $user_info['email'];
					$data['User']['register_using'] = 2;
					$data['User']['status'] = 1;
					$slug = $this->User->generate_user_slug($user_info['name'].'-'.$user_info['name']);
					$data['User']['slug'] = $slug;
					$password = rand();
					$data['User']['password'] = $password;
					
					if($this->User->save($data))
					{   						 
                        $res_arr['result']['user_id'] = $this->User->id;
						$res_arr['result']['email']   = $user_info['email'];
						$res_arr['result']['name']    = $user_info['name'];
						$res_arr['result']['address'] = '';
						$res_arr['result']['phone_no']= '';
						$res_arr['result']['dob']     = '';		
						$res_arr['result']['badge']   = 'Beginner';                                                
						$res_arr['result']['profile_img'] = (!empty($data['User']['profile_img']))? SITE_URL.UPLOAD_USERS_DIR.$data['User']['profile_img'] : 1;
						$res_arr['msg'] =  'User successful registred with facebook';
						$res_arr['status'] = 1;
                                                
						// Sending Login credentials Mail.

						$email = new CakeEmail();
						$email->template('registration_success');
						$email->emailFormat('html');
						$email->subject(__('Login credentials'));
						$email->viewVars(array('pass' => $password, 'name'=> $user_info['name'], 'email' => $user_info['email']));
						$email->to($user_info['email']);
						$email->from('info@aasaan.com');
						$email->send();						
					}
				}
				
				elseif(!empty($fbregister_user_email) && empty($fbregister_user))
				{
					$data['User']['id'] = $fbregister_user_email['User']['id'];
					$data['User']['fb_id'] = $user_info['FbId'];
					$slug = $this->User->generate_user_slug($fbregister_user_email['User']['display_name'].'-'.$fbregister_user_email['User']['display_name']);
					$data['User']['slug'] = $slug;				
					$data['User']['status_type'] = 1;	
					$data['User']['status'] = 1;				
					$data['User']['register_using'] = 2;
					if($this->User->save($data))
					{
                        $res_arr['result']['user_id'] = $fbregister_user_email['User']['id'];
						$res_arr['result']['email']   = $fbregister_user_email['User']['email'];
						$res_arr['result']['name']    = $fbregister_user_email['User']['display_name'];
						$res_arr['result']['address'] = $fbregister_user_email['User']['address'];
						$res_arr['result']['phone_no']= $fbregister_user_email['User']['phone_no'];
						$res_arr['result']['dob']     = $fbregister_user_email['User']['dob'];		
						 $this->LoadModel('Setting');
						$states = $this->Setting->find('first', array('conditions' => array('key' => 'stats')));			
						$setting_stats_val = unserialize($states['Setting']['val']);
						$badge = '';	
						$arr_totpoint_rating_val  = $this->get_user_totpoint_rating_val($fbregister_user_email['User']['id']);
						foreach($setting_stats_val['batches'] as $batch_key => $row_batch)
						{							
							if($arr_totpoint_rating_val['tot_user_point'] >= $row_batch['from'] && $arr_totpoint_rating_val['tot_user_point'] <= $row_batch['to'])
							{
								$badge = $row_batch['name'];
								break;
							}
						}
						$res_arr['result']['badge'] 		   = $badge;                      
						$res_arr['result']['profile_img'] = (!empty($fbregister_user_email['User']['profile_img']))? SITE_URL.UPLOAD_USERS_DIR.$fbregister_user_email['User']['profile_img'] : 1;
						$res_arr['msg'] =  'User already registered';
						$res_arr['status'] = 1;						
					}
				}
				elseif(!empty($fbregister_user))
				{
					$data['User']['id'] = $fbregister_user['User']['id'];
					$data['User']['type'] = 'User';
					$slug = $this->User->generate_user_slug($fbregister_user['User']['display_name'].'-'.$fbregister_user['User']['display_name']);
					$data['User']['slug'] = $slug;	
					 
					if($this->User->save($data))
					{
						//$res_arr['data']['user_id'] = $fbregister_user['User']['id'];
						$res_arr['result']['user_id'] = $fbregister_user['User']['id'];
						$res_arr['result']['email']   = $fbregister_user['User']['email'];
						$res_arr['result']['name']    = $fbregister_user['User']['display_name'];
						$res_arr['result']['address'] = $fbregister_user['User']['address'];
						$res_arr['result']['phone_no']= $fbregister_user['User']['phone_no'];
						$res_arr['result']['dob']     = $fbregister_user['User']['dob'];
                        $this->LoadModel('Setting');
						$states = $this->Setting->find('first', array('conditions' => array('key' => 'stats')));			
						$setting_stats_val = unserialize($states['Setting']['val']);
						$badge = '';	
						$arr_totpoint_rating_val 		       = $this->get_user_totpoint_rating_val($fbregister_user['User']['id']);
						foreach($setting_stats_val['batches'] as $batch_key => $row_batch)
						{							
							if($arr_totpoint_rating_val['tot_user_point'] >= $row_batch['from'] && $arr_totpoint_rating_val['tot_user_point'] <= $row_batch['to'])
							{
								$badge = $row_batch['name'];
								break;
							}
						}                       
						$res_arr['result']['badge'] 		   = $badge;
                        $res_arr['result']['avatar'] = (!empty($fbregister_user['User']['avatar']))?$fbregister_user['User']['avatar']:1;
						$res_arr['result']['profile_img'] = (!empty($fbregister_user['User']['profile_img']))? SITE_URL.UPLOAD_USERS_DIR.$fbregister_user['User']['profile_img'] : 1;
						$res_arr['msg'] =  'User already registered';
						$res_arr['status'] = 1;
					}
				}
				else
				{
					$res_arr['message'] = 'You are not authorized to access';
					$res_arr['status'] = 'faliure';
				}
			}
                        
             elseif(isset($user_info['GlId']) && !empty($user_info['GlId']))
			{ 
                $glregister_user_email = $this->User->find('first', array('conditions' => array('email' => $user_info['email'])));
				$glregister_user = $this->User->find('first', array('conditions' => array('google_id' => $user_info['GlId'])));
				if (empty($glregister_user_email) && empty($glregister_user) && !isset($user_info['Pass']))
				{
					$data['User']['google_id'] = $user_info['GlId'];
					$data['User']['display_name'] = $user_info['name'];
					$data['User']['first_name'] = $user_info['name'];
					$slug = $this->User->generate_user_slug($user_info['name'].'-'. $user_info['name']);
					$data['User']['slug'] = $slug;
					$data['User']['email'] = $user_info['email'];
					$password = rand(); // Genrating Random password if user first time login with facebook
					$data['User']['password'] = $password;
					$data['User']['register_using'] = 6;
					$data['User']['status'] = 1;
					if($this->User->save($data))
					{
						$res_arr['result']['user_id'] =  $this->User->id;
						$res_arr['result']['email']   = $user_info['email'];
						$res_arr['result']['name']    = $user_info['name'];
						$res_arr['result']['address'] = '';
						$res_arr['result']['phone_no']= '';
						$res_arr['result']['dob']     = '';	
						$res_arr['result']['badge']   = 'Beginner';                         
						$res_arr['result']['profile_img'] = (!empty($data['User']['profile_img']))? SITE_URL.UPLOAD_USERS_DIR.$data['User']['profile_img'] : 1;
						$res_arr['msg'] =  'User successful registred with google';
						$res_arr['status'] = 1;
						$email = new CakeEmail();
						$email->template('registration_success');
						$email->emailFormat('html');
						$email->subject(__('Login credentials'));
						$email->viewVars(array('pass' => $password, 'name'=> $user_info['name'], 'email' => $user_info['email']));
						$email->to($user_info['email']);
						$email->from('info@aasaan.com');						
					}
				}				
				elseif(!empty($glregister_user_email) && empty($glregister_user))
				{
					$data['User']['id'] = $glregister_user_email['User']['id'];
					$data['User']['google_id'] = $user_info['GlId'];
					//$data['User']['join_ip'] = $user_info['DeviceToken'];
					$data['User']['status_type'] = 0;					
					$slug = $this->User->generate_user_slug($glregister_user_email['display_name'].'-'. $glregister_user_email['display_name']);
					$data['User']['slug'] = $slug;
					$data['User']['register_using'] = 6;
					$data['User']['status'] = 1;
					if($this->User->save($data))
					{
                                                $res_arr['result']['user_id'] = $glregister_user_email['User']['id'];
						$res_arr['result']['email']   = $glregister_user_email['User']['email'];
						$res_arr['result']['name']    = $glregister_user_email['User']['display_name'];
						$res_arr['result']['address'] = $glregister_user_email['User']['address'];
						$res_arr['result']['phone_no']= $glregister_user_email['User']['phone_no'];
						$res_arr['result']['dob']     = $glregister_user_email['User']['dob'];	
						 $this->LoadModel('Setting');
						$states = $this->Setting->find('first', array('conditions' => array('key' => 'stats')));			
						$setting_stats_val = unserialize($states['Setting']['val']);
						$badge = '';	
						$arr_totpoint_rating_val 		       = $this->get_user_totpoint_rating_val($fbregister_user_email['User']['id']);
						foreach($setting_stats_val['batches'] as $batch_key => $row_batch)
						{							
							if($arr_totpoint_rating_val['tot_user_point'] >= $row_batch['from'] && $arr_totpoint_rating_val['tot_user_point'] <= $row_batch['to'])
							{
								$badge = $row_batch['name'];
								break;
							}
						}
                                                //echo '<pre>'; var_dump($badge); die;
						$res_arr['result']['badge'] 		   = $badge;
                        $res_arr['result']['avatar'] = (!empty($glregister_user_email['User']['avatar']))?$glregister_user_email['User']['avatar']:1;
						$res_arr['result']['profile_img'] = (!empty($glregister_user_email['User']['profile_img']))? SITE_URL.UPLOAD_USERS_DIR.$glregister_user_email['User']['profile_img'] : 1;
						$res_arr['msg'] =  'User already registered';
						$res_arr['status'] = 1;
					}
				}
				elseif(!empty($glregister_user))
				{
					$data['User']['id'] = $glregister_user['User']['id'];
					//$data['User']['device_token'] = $user_info['DeviceToken'];
					$data['User']['type'] = 'User';	
					$slug = $this->User->generate_user_slug($glregister_user['display_name'].'-'. $glregister_user['display_name']);
					$data['User']['slug'] = $slug;
					if($this->User->save($data))
					{
						$res_arr['result']['user_id'] = $glregister_user['User']['id'];
						$res_arr['result']['email']   = $glregister_user['User']['email'];
						$res_arr['result']['name']    = $glregister_user['User']['display_name'];
						$res_arr['result']['address'] = $glregister_user['User']['address'];
						$res_arr['result']['phone_no']= $glregister_user['User']['phone_no'];
						$res_arr['result']['dob']     = $glregister_user['User']['dob'];		
						 $this->LoadModel('Setting');
						$states = $this->Setting->find('first', array('conditions' => array('key' => 'stats')));			
						$setting_stats_val = unserialize($states['Setting']['val']);
						$badge = '';	
						$arr_totpoint_rating_val 		       = $this->get_user_totpoint_rating_val($fbregister_user_email['User']['id']);
						foreach($setting_stats_val['batches'] as $batch_key => $row_batch)
						{							
							if($arr_totpoint_rating_val['tot_user_point'] >= $row_batch['from'] && $arr_totpoint_rating_val['tot_user_point'] <= $row_batch['to'])
							{
								$badge = $row_batch['name'];
								break;
							}
						}                        
						$res_arr['result']['badge'] 		   = $badge;
						$res_arr['result']['avatar'] = (!empty($glregister_user['User']['avatar']))?$glregister_user['User']['avatar']:1;
						$res_arr['result']['profile_img'] = (!empty($glregister_user['User']['profile_img']))? SITE_URL.UPLOAD_USERS_DIR.$glregister_user['User']['profile_img'] : 1;
						$res_arr['msg'] =  'User already Registered';
						$res_arr['status'] = 1;
					}
				}
				else
				{
					$res_arr['message'] = 'You are not authorized to access';
					$res_arr['status'] = 'faliure';
				}
			}
			else
			{
				if (empty($fbregister_user_email) && empty($glregister_user_email) && empty($user_info['FbId']))
				{
					$data['User']['display_name'] = $user_info['name'];
					$data['User']['first_name'] = $user_info['name'];
					$data['User']['email']        = $user_info['email'];					
					$data['User']['password']     = $user_info['password'];
					$data['User']['device_type']  = $user_info['deviceType'];
					$data['User']['device_id']    = $user_info['deviceId'];
					$data['User']['app_version']  = $user_info['appVersion'];
					$data['User']['user_type']    = 2;
					$data['User']['status']       = 2;
					$data['User']['register_using'] = 1;
					$ver_code = $this->Auth->password(uniqid());				
					$data['User']['verification_code'] = $ver_code;
					$slug = $this->User->generate_user_slug($user_info['name'].'-'. $user_info['name']);
					$data['User']['slug'] = $slug;
									    
					if($this->User->save($data, array('validate' => false)))
					{					
						$res_arr['msg'] =  'Please check your mail and verify your account.';
						$res_arr['status'] = 3;						
						$this->loadModel('EmailTemplate');					
						$ver_link = SITE_URL.'user/verification/'.$ver_code;
						$srch_array = array("{{username}}" => ucwords($user_info['name']), "{{activationlink}}" => $ver_link);
						$email_values = $this->EmailTemplate->getvalues('user_registration', $srch_array);

						$this->Email->from = $email_values['from_name'].' <'.$email_values['from_emailid'].'>';
						$this->Email->to = $user_info['email'];
						$this->Email->subject = $email_values['subject'];
						$this->Email->sendAs = 'html';
						$this->Email->smtpOptions = Configure::read('EMAIL_CONFIG');
						$this->Email->delivery = EMAIL_DELIVERY;
						$this->Email->send($email_values['content']);
					}
					else
					{
                       $res_arr['msg'] =  'User not registered';
					   $res_arr['status'] = 0;
					}
				}
				else
				{					
					$res_arr['msg'] =  'User already registered';
					$res_arr['status'] = 0;
				}
			}
		}
		else
		{
			$res_arr['msg'] =  'Invalid request';
			$res_arr['status'] = 0;
		}
		echo json_encode($res_arr);
		exit;
	}
	
	function edit_profile()
	{			 
		$this->loadModel('User');
		$res_arr = $result = array();		
		if(!empty($this->request->data))
		{			 
			$user_info = $this->request->data;
			$cond = array('User.id' => $user_info['user_id']);
			$user = $this->User->find('first', array('conditions' => $cond));
			if(!empty($user)){
				$imageName = $user['User']['profile_img'];
				if (!isset($user_info['profileImage'])  && !empty($_FILES['profileImage']['name'])) {
						$user_info['profileImage'] = $_FILES['profileImage'];					
						$name = explode('.',$user_info['profileImage']['name']);
						$extention = end($name);
						if ($extention == 'png' || $extention == 'jpg' || $extention == 'jpeg' || $extention == 'bmp' || $extention == 'gif' ) {
							$imageName = time().'.'.$extention;
							  $moveFile = WWW_ROOT.'uploads/users/'.$imageName ;

							if (move_uploaded_file($user_info['profileImage']['tmp_name'], $moveFile)) {
								$data['User']['profile_img'] = $imageName;	
							}
						}						
				    }
				$data['User']['display_name'] = $user_info['name'];
				$data['User']['phone_no'] 	  = $user_info['phone_no'];
				$data['User']['address'] 	  = $user_info['address'];				
				$data['User']['dob'] 		  =$user_info['dob'];
				$this->User->id = $user_info['user_id'];
				if($this->User->save($data))
				{
					$res_arr['result']['user_id'] = $this->User->id;
					$res_arr['result']['email']   = $user['User']['email'];
					$res_arr['result']['name']    = $user_info['name'];
					$res_arr['result']['address'] = $user_info['address'];
					$res_arr['result']['phone_no']= $user_info['phone_no'];
					$res_arr['result']['dob']     = $user_info['dob'];
					$res_arr['result']['badge']   = 'Beginner';
					$res_arr['result']['profile_img'] = (!empty($imageName) ? SITE_URL.UPLOAD_USERS_DIR.$imageName : 1);
					$res_arr['msg'] =  'User profile updated successfully';
					$res_arr['status'] = 1;
				}
			}
			else
			{					
				$res_arr['msg'] =  "User doesn't exists";
				$res_arr['status'] = 0;
			}
		}
		else
		{
			$res_arr['msg'] =  'Invalid request';
			$res_arr['status'] = 0;
		}
		echo json_encode($res_arr);
		exit;
	}		

	function login()
	{		
		$res_arr = $result = array();		
		$this->loadModel('User');
		if(!empty($this->request->data))
		{
			$user_info = $this->request->data;
			$id = (isset($user_info['socialid']) && $user_info['socialid'] !='' ? $user_info['socialid'] : '');
			if(isset($id) && !empty($id))
			{				
				$fbregister_user = $this->User->find('first', array('conditions' => array('or' => array('google_id' => $id, 'facebook_id' => $id))));
				if (!empty($fbregister_user))
				{
						$user = $fbregister_user['User'];
						$res_arr['result']['user_id'] = $user['id'];
						$res_arr['result']['email']   = $user['email'];
						$res_arr['result']['name']    = $user['display_name'];
						$res_arr['result']['address'] = $user['address'];
						$this->LoadModel('Setting');
						$states = $this->Setting->find('first', array('conditions' => array('key' => 'stats')));			
						$setting_stats_val = unserialize($states['Setting']['val']);
						$badge = '';						
						$arr_totpoint_rating_val 		       = $this->get_user_totpoint_rating_val($user['id']);
						foreach($setting_stats_val['batches'] as $batch_key => $row_batch)
						{							
							if($arr_totpoint_rating_val['tot_user_point'] >= $row_batch['from'] && $arr_totpoint_rating_val['tot_user_point'] <= $row_batch['to'])
							{
								$badge = $row_batch['name'];break;
							}
						}
						$res_arr['result']['badge'] 		   = $badge;
						$res_arr['result']['profile_img'] = (!empty($user['profile_img']))? SITE_URL.UPLOAD_USERS_DIR.$user['profile_img'] : 1;
						$res_arr['msg'] =  'User successfully login';
						$res_arr['status'] = 1;
						$res_arr['result']['phone_no']= $user['phone_no'];
						$res_arr['result']['dob']     = $user['dob'];						
						echo json_encode($res_arr);
						exit;			
				}
				else
				{
						$res_arr['status'] = 2;						
						echo json_encode($res_arr);
						exit;
				}
			}
				
			$register_user_email = $this->User->find('first', array('conditions' => array('email' => $user_info['email'])));
			$user = $register_user_email['User'];
			if(!empty($register_user_email))
			{
				if ($register_user_email['User']['status'] == 1)
				{					
					if( $this->Auth->password($user_info['password']) == $user['password'])
					{
						
						$res_arr['result']['user_id'] = $user['id'];
						$res_arr['result']['email']   = $user['email'];
						$res_arr['result']['name']    = $user['display_name'];
						$res_arr['result']['address'] = $user['address'];
						
						$this->LoadModel('Setting');
						$states = $this->Setting->find('first', array('conditions' => array('key' => 'stats')));			
						$setting_stats_val = unserialize($states['Setting']['val']);
						$badge = '';						
						$arr_totpoint_rating_val 		       = $this->get_user_totpoint_rating_val($user['id']);
						foreach($setting_stats_val['batches'] as $batch_key => $row_batch)
						{							
							if($arr_totpoint_rating_val['tot_user_point'] >= $row_batch['from'] && $arr_totpoint_rating_val['tot_user_point'] <= $row_batch['to'])
							{
								$badge = $row_batch['name'];
								break;
							}
						}
						$res_arr['result']['badge'] 		   = $badge;
						
						$res_arr['result']['profile_img'] = (!empty($user['profile_img']))? SITE_URL.UPLOAD_USERS_DIR.$user['profile_img'] : 1;
						$res_arr['msg'] =  'User successfully login';
						$res_arr['status'] = 1;
						
						$this->User->id = $user['id'];
						$data['User']['device_type']  = $user_info['deviceType'];
						$data['User']['device_id']    = $user_info['deviceId'];
						$data['User']['app_version']  = $user_info['appVersion'];					
						$data['User']['app_version']  = $user_info['appVersion'];							
						$res_arr['result']['phone_no']= $user['phone_no'];
						$res_arr['result']['dob']     = $user['dob'];				
						$data['User']['last_login ']  = date('Y-m-d H:i:s');						
						$res_arr['result']['user_type']= $user['user_type'];					
						$this->User->save($data);
					}
					else
					{
						$res_arr['msg'] =  'Please enter the valid email and password.';
						$res_arr['status'] = 0;
					}
				}
				else
				{
					$res_arr['msg'] =  'User account currently not activated.';
					$res_arr['status'] = 3;
				}
			}
			else
			{
				$res_arr['msg'] =  'Please enter the valid email and password field.';
				$res_arr['status'] = 0;
			}
		}
		else
		{
			$res_arr['msg'] =  'Invalid post request';
			$res_arr['status'] = 0;
		}
		echo json_encode($res_arr);
		exit;
	}
	
	function addNewCompany()
	{
		$this->loadModel('OutletName');		
		$this->loadModel('Landmark');		
		
		$ARR_STATES = Configure::read('ARR_STATES');
		$ARR_LTYPE = Configure::read('ARR_LICENCE_TYPE');
		
		$error_flag = false;
		$msg_arr = array('status'=>201,'message'=>'invalid data format');
		$state  = Configure::read('ARR_STATES');
		$this->loadModel('OutletName');
		if(!empty($this->request->data))
		{			
			$arr_comp_data = $this->request->data;
			$found = true;
			if($this->OutletName->find('first', array('conditions' => array('licence_no' => $arr_comp_data['licence_no']))))
			{
				$msg_arr = array('status'=> 0, 'msg'=>'licence no. already exists.');
				$found = false;
			}
			else  if($this->OutletName->find('first', array('conditions' => array('email' => $arr_comp_data['email']))))
			{
				$msg_arr = array('status'=> 0, 'msg'=>'Email already exists');
				$found = false;
			}
			
			if($found)
			{
				if (!empty($_FILES['profileImage']['name'])) {
					$user_info['profileImage'] = $_FILES['profileImage'];							
				}			
				if(isset($user_info['profileImage']) && !empty($user_info['profileImage']))
				{
					$name = explode('.',$user_info['profileImage']['name']);						
					$extention = end($name);
					if ($extention == 'png' || $extention == 'jpg' || $extention == 'jpeg' || $extention == 'bmp' || $extention == 'gif' ) {
						$imageName = time().'.'.$extention;                                                        
						$moveFile =UPLOAD_OUTLET_DIR.$imageName ;
						if(move_uploaded_file($user_info['profileImage']['tmp_name'], $moveFile)) {
							$data_arr['OutletName']['logo'] = $imageName;	
						}
					}						
				}
				$data_arr['OutletName']['user_id'] = $arr_comp_data['userId'];
				$data_arr['OutletName']['title'] = $arr_comp_data['name'];
				$data_arr['OutletName']['phone_no'] 	= $arr_comp_data['phone_no1'];
				$data_arr['OutletName']['licence_type'] = $arr_comp_data['licenceType'];
				$data_arr['OutletName']['no_store'] = $arr_comp_data['noOfStore'];
				$data_arr['OutletName']['phone_no2'] = $arr_comp_data['phone_no2'];	
				$data_arr['OutletName']['state']   = $arr_comp_data['city'];			
				$data_arr['OutletName']['zipcode'] = $arr_comp_data['postBox'];
				$data_arr['OutletName']['street']  = $arr_comp_data['street'];
				$data_arr['OutletName']['building_no'] = (isset($arr_comp_data['building']) ? $arr_comp_data['building'] : '');
				$data_arr['OutletName']['personal_no'] = (isset($arr_comp_data['contactMob']) ? $arr_comp_data['contactMob'] : '') ;
				$data_arr['OutletName']['mobile'] = $arr_comp_data['contactMob'];
				$data_arr['OutletName']['licence_no'] = $arr_comp_data['licence_no'];
				$data_arr['OutletName']['fax'] = $arr_comp_data['faxNO'];
				$data_arr['OutletName']['website'] = $arr_comp_data['compWebAddr'];
				$data_arr['OutletName']['contact_person'] = $arr_comp_data['contactPerson'];
				$data_arr['OutletName']['email'] = $arr_comp_data['email'];
				$data_arr['OutletName']['city']	 = $arr_comp_data['area'];
				$data_arr['OutletName']['landmark_id'] = $arr_comp_data['landmark'];
				$data_arr['OutletName']['extra_data'] = serialize($arr_comp_data);		
				
				if($this->OutletName->save($data_arr, array('validate' => false)))				
				{
					$msg_arr = array('status'=> 1, 'msg'=>'Saved successfully.');					
				}
				else
				{
					$msg_arr = array('status'=> 0, 'msg'=>'Something went wrong');
				}
			}
		}
			echo json_encode($msg_arr);
			exit;
	}
	
	function editCompany()
	{		
		$this->loadModel('OutletName');		
		$this->loadModel('Landmark');		
		
		$ARR_STATES = Configure::read('ARR_STATES');
		$ARR_LTYPE = Configure::read('ARR_LICENCE_TYPE');
		
		$error_flag = false;
		$msg_arr = array('status'=>201,'message'=>'invalid data format');
		$state  = Configure::read('ARR_STATES');
		$this->loadModel('OutletName');
		Configure::write('debug',2);
		if(!empty($this->request->data))
		{			
			$arr_comp_data = $this->request->data;
			$user_id = $arr_comp_data['userId'];
			$found = true;
			if($this->OutletName->find('first', array('conditions' => array('user_id !=' => $user_id, 'licence_no' => $arr_comp_data['licence_no']))))
			{
				$msg_arr = array('status'=> 0, 'msg'=>'licence no. already exists.');
				$found = false;
			}
			
			if($found)
			{
				if (!empty($_FILES['profileImage']['name'])) {
					$user_info['profileImage'] = $_FILES['profileImage'];							
				}			
				if(isset($user_info['profileImage']) && !empty($user_info['profileImage']))
				{
					$name = explode('.',$user_info['profileImage']['name']);						
					$extention = end($name);
					if ($extention == 'png' || $extention == 'jpg' || $extention == 'jpeg' || $extention == 'bmp' || $extention == 'gif' ) {
						$imageName = time().'.'.$extention;                                                        
						$moveFile =UPLOAD_OUTLET_DIR.$imageName ;
						if(move_uploaded_file($user_info['profileImage']['tmp_name'], $moveFile)) {
							$data_arr['OutletName']['logo'] = $imageName;	
						}
					}						
				}
				$data_arr['OutletName']['user_id'] = $arr_comp_data['userId'];
				$data_arr['OutletName']['title'] = $arr_comp_data['name'];
				$data_arr['OutletName']['phone_no'] 	= $arr_comp_data['phone_no1'];
				$data_arr['OutletName']['licence_type'] = $arr_comp_data['licenceType'];
				$data_arr['OutletName']['no_store'] = $arr_comp_data['noOfStore'];
				$data_arr['OutletName']['phone_no2'] = $arr_comp_data['phone_no2'];	
				$data_arr['OutletName']['state']   = $arr_comp_data['city'];			
				$data_arr['OutletName']['zipcode'] = $arr_comp_data['postBox'];
				$data_arr['OutletName']['street']  = $arr_comp_data['street'];
				$data_arr['OutletName']['building_no'] = (isset($arr_comp_data['building']) ? $arr_comp_data['building'] : '');
				$data_arr['OutletName']['personal_no'] = (isset($arr_comp_data['contactMob']) ? $arr_comp_data['contactMob'] : '') ;
				$data_arr['OutletName']['mobile'] = $arr_comp_data['contactMob'];
				$data_arr['OutletName']['licence_no'] = $arr_comp_data['licence_no'];
				$data_arr['OutletName']['fax'] = $arr_comp_data['faxNO'];
				$data_arr['OutletName']['website'] = $arr_comp_data['compWebAddr'];
				$data_arr['OutletName']['contact_person'] = $arr_comp_data['contactPerson'];
				$data_arr['OutletName']['email'] = $arr_comp_data['email'];
				$data_arr['OutletName']['city']	 = $arr_comp_data['area'];
				$data_arr['OutletName']['landmark_id'] = $arr_comp_data['landmark'];
				$data_arr['OutletName']['extra_data'] = serialize($arr_comp_data);	
				$id = $this->OutletName->find('first', array('conditions' => array('user_id' => $user_id)));	
				$this->OutletName->id = $id['OutletName']['id'];
				
				if($this->OutletName->save($data_arr, array('validate' => false)))				
				{
					$msg_arr = array('status'=> 1, 'msg'=>'Updated successfully.');					
				}
				else
				{
					$msg_arr = array('status'=> 0, 'msg'=>'Something went wrong');
				}
			}
		}
			echo json_encode($msg_arr);
			exit;
	}
	
	function companyDetails($id = null)
	{
		Configure::write('debug',2);
		$error_flag = false;
		$msg_arr = array('status'=>201,'msg'=>'invalid data format');	
		$this->loadModel('OutletName');
		$this->loadModel('State');
		$this->loadModel('City');
		$this->loadModel('Landmark');
		if($id != null)
		{
			$data = $this->OutletName->find('first', array('conditions' => array('user_id' => $id)));
			if(count($data))
			{
				$dataFull = array();
				foreach($data['OutletName'] as $k => $v)
				{
					if($k == 'state')
					{
						$state = $this->State->find('first', array('conditions' => array('id' => $v)));
						$dataFull['state_name'] = (isset($state['State']['title']) ? $state['State']['title'] : '');
					}
					else if($k == 'city')
					{
						$state = $this->City->find('first', array('conditions' => array('id' => $v)));
						$dataFull['city_name'] = (isset($state['City']['title']) ? $state['City']['title'] : '');
					}
					else if($k == 'landmark_id')
					{
						$state = $this->Landmark->find('first', array('conditions' => array('id' => $v)));
						$dataFull['landmark_name'] = (isset($state['Landmark']['title']) ? $state['Landmark']['title'] : '' );
					}		
					$dataFull[$k] = ($v == null ? '' : $v);
				}
				$msg_arr = array('status'=>1,'image' => DISPLAY_OUTLET_DIR, 'data'=> $dataFull);
			}
			else
			{
				$msg_arr = array('status'=>0,'msg'=>'No compnay found');
			}
		}
		echo json_encode($msg_arr);
		exit;
	}

	function outletDetails($id = null)// for Outlet owner
	{
		Configure::write('debug',2);
		$error_flag = false;
		$msg_arr = array('status'=>201,'msg'=>'invalid data format');	
		$this->loadModel('OutletName');
		$this->loadModel('State');
		$this->loadModel('City');
		$this->loadModel('Landmark');
		$this->loadModel('Outlet');
		if($id != null)
		{
			$joins = array(
			array(
				'table' => 'cities',
				'alias' => 'City',
				'type' => 'left',
				'conditions' => array('City.id = Outlet.city')
			),
			array(
				'table' => 'outlet_names', 
				'alias' => 'OutletName',
				'type' => 'left',
				'conditions' => array('OutletName.id = Outlet.outlet_name_id')
			 ),			
			); 
			$this->Outlet->bindModel(array(
				'hasMany' => array(
					'Filerec' => array(
						'foreignKey' => 'ref_id',
						'conditions' => array('Filerec.ref_type=1')                                            
					),
				   'Offer'						
				)
			));	
			$this->Outlet->recursive = 1;	
			$data = $this->Outlet->find('first', array('join' => $joins, 'conditions' => array('id' => $id)));
			$dataFull = array();
			if(count($data))
			{
				$dataFull = $data['Outlet'];
				$state = $this->State->find('first', array('conditions' => array('id' => $data['Outlet']['state'])));
				$dataFull['state_name'] = (isset($state['State']['title']) ? $state['State']['title'] : '');
				$state = $this->City->find('first', array('conditions' => array('id' => $data['Outlet']['city'])));
				$dataFull['city_name'] = (isset($state['City']['title']) ? $state['City']['title'] : '');
				$state = $this->Landmark->find('first', array('conditions' => array('id' => $data['Outlet']['landmark_id'])));
				$dataFull['landmark_name'] = (isset($state['Landmark']['title']) ? $state['Landmark']['title'] : '' );
				
				$dataFull['imagelist'] = $dataFull['subcatname_list'] = $dataFull['subcatid_list'] = '';
				if(count($data['Filerec']))
				{
					$fileName = array();
					foreach ($data['Filerec'] as $key => $value) {
						$fileName[] = $value['file_name'];
					}
					$dataFull['imagelist'] = implode(',', $fileName);
				}
				if(count($data['Category']))
				{
					$name = $subids = array();
					foreach ($data['Category'] as $key => $value) {
						$name[]   = $value['title'];
						$subids[] = $value['id'];
					}
					$dataFull['subcatid_list'] = implode(',', $subids);
					$dataFull['subcatname_list'] = implode(',', $name);
				}
				$msg_arr = array('status'=>1,'image' => DISPLAY_OUTLET_DIR, 'data'=> $dataFull);
			}
			else
			{
				$msg_arr = array('status'=>0,'msg'=>'No compnay found');
			}
		}
		echo json_encode($msg_arr);
		exit;
	}
	
	function getStoreList()
	{	
		
		$res_arr = $result = array();
		$this->loadModel('Outlet');
		$userId = $this->request->data['userId'];
		$joins = array(
				'table' => 'outlet_names', 
				'alias' => 'OutletName',
				'type' => 'left',
				'conditions' => array('OutletName.id = Outlet.outlet_name_id')
			);
		$data =$this->Outlet->find('all', array(
					'fields' => array('Outlet.id','Outlet.title', 'OutletName.title', 'Outlet.status'),
					'conditions' => array('Outlet.user_id' => $userId),
					'joins' => array($joins),					
					)
				);
		
		if(count($data))
		{
			$res_arr['status']  = 1;
			$i = 0;
			foreach($data as $d)
			{
				$res_arr['Outlet'][$i]['title']  = $d['Outlet']['title'];
				$res_arr['Outlet'][$i]['name']   = $d['OutletName']['title'];
				$res_arr['Outlet'][$i]['status'] = $d['Outlet']['status'];
				$res_arr['Outlet'][$i]['id']     = $d['Outlet']['id'];
				$i++;
			}
		}
		else
		{
			$res_arr['msg'] =  'No store found';
			$res_arr['status'] = 0;
		}
		echo json_encode($res_arr);
		exit;
	}
	
	function getCompanyList()
	{	
		$res_arr = $result = array();
		$this->loadModel('OutletNames');
		$userId = $this->request->data['userId'];
	
		$data = $this->OutletNames->find('all', array('conditions' => array('user_id' => $userId)));
		if(count($data))
		{
			$res_arr['status']  = 1;
			$i = 0;
			foreach($data as $d)
			{
				$res_arr['Company'][$i]['title']  = $d['OutletNames']['title'];
				$res_arr['Company'][$i]['email']  = $d['OutletNames']['email'];
				$res_arr['Company'][$i]['status'] = $d['OutletNames']['status'];
				$res_arr['Company'][$i]['id']     = $d['OutletNames']['id'];
				$i++;
			}
		}
		else
		{
			$res_arr['msg'] =  'No store found';
			$res_arr['status'] = 0;
		}
		echo json_encode($res_arr);
		exit;		
		
	}
	
	function getAccount(){
		$res_arr = $result = array();		
		$this->loadModel('User');
		$this->loadModel('OutletName');
		if(!empty($this->request->data))
		{
			$userId = $this->request->data['userId'];
			$info = $this->User->findById($userId);
			$user = $info['User'];
			$res_arr['result']['name']     = $user['display_name'];			
			$res_arr['result']['user_id']  = $userId;			
			$res_arr['result']['email']    = $user['email'];			
			$res_arr['result']['address']  = $user['address'];
			$res_arr['result']['phone_no']= $user['phone_no'];
			$res_arr['result']['dob']     = $user['dob'];	
			$res_arr['result']['user_type']= $user['user_type'];
			$company = $this->OutletName->find('first', array('conditions' => array('user_id' => $userId)));
			$res_arr['result']['company_id'] = (isset($company['OutletName']['id']) ? $company['OutletName']['id'] : 0);
			$res_arr['result']['profile_img'] = (!empty($user['profile_img']))? SITE_URL.UPLOAD_USERS_DIR.$user['profile_img'] : 1;			
			$res_arr['status'] = 1;
			
			$this->LoadModel('Review');			
			$this->LoadModel('Like');
			$this->LoadModel('Setting');
			$result = $this->Setting->find('first', array('fields' => array('val', 'key'), 'conditions' => array('Setting.key' => 'stats')));
			$num_reviews = $this->Review->find('count', array('conditions' => array('Review.review !=' => '','Review.user_id' => $userId, 'Review.type' => 'outlet','Review.status' => 1)));
			$num_bookmarks = $this->Like->find('count', array('conditions' => array('Like.user_id' => $userId, 'Like.ref_type' => '1', 'Like.type' => 'bookmark')));
			$num_like = $this->Like->find('count', array('conditions' => array('Like.user_id' => $userId, 'Like.ref_type' => '1', 'Like.type' => 'like')));
			$res_arr['result']['review_count'] = $num_reviews;
			$badge = $total='';
			if(!empty($result))
			{				
				if(!empty($result['Setting']['val']))
				{
					$sval = unserialize($result['Setting']['val']);
					$point_review   = $sval['points']['review'];
					$point_bookmark = $sval['points']['bookmark'];
					$point_like     = $sval['points']['outlet_like'];	
					$total = ($num_bookmarks*$point_bookmark)+($point_review*$num_reviews)+($point_like*$num_like);					
				}					
				foreach($sval['batches'] as $batch_key => $row_batch)
				{
					if($total >= $row_batch['from'] && $total <= $row_batch['to'])
					{
						$badge = $row_batch['name'];
						break;
					}
				}
			}
			$res_arr['result']['statistics_count'] = $total;
			$res_arr['result']['badge'] 		   = $badge;
			$res_arr['result']['bookmark_count']   = $this->Like->find('count', array('conditions' => array('Like.user_id' => $userId, 'Like.ref_type' => '1', 'Like.type' => 'bookmark')));
		}
		else
		{
			$res_arr['msg'] =  'Invalid post request';
			$res_arr['status'] = 0;
		}
		echo json_encode($res_arr);
		exit;	
	}
	
	function getcat_subCat()
	{
		/*if($id == null){
			$this->loadModel('ParentCategory');
			$arr = $this->ParentCategory->find('all',array('order'=>'parcatorder asc'));			
			$i = 0;
			$img = array('grocer','home-maintainence','pharmacy','laundary','florist','car-maintanence','petcare');
			foreach($arr as $j){
				$cat[$i]['id'] = $j['ParentCategory']['id'];
				$cat[$i]['name'] = $j['ParentCategory']['name'];
				yh 
				if(!file_exists(UPLOAD_CATEGORY_DIR.'80x80_'.$j['ParentCategory']['image'])){				
					$this->Image->resize_crop_image(80,80, UPLOAD_CATEGORY_DIR.$j['ParentCategory']['image'], UPLOAD_CATEGORY_DIR.'80x80_'.$j['ParentCategory']['image']);
				}
                $cat[$i]['image_ipad'] = SITE_URL.'uploads/category/768x210_'.$j['ParentCategory']['image'];
                $cat[$i]['image_6S'] 	   = SITE_URL.'uploads/category/414x151_'.$j['ParentCategory']['image'];
                $cat[$i]['image'] 	  	 = SITE_URL.'uploads/category/320x151_'.$j['ParentCategory']['image'];
                $cat[$i]['image_80'] 	   = SITE_URL.'uploads/category/80x80_'.$j['ParentCategory']['image'];
				$i++;
			}
			$result['category'] = $cat;
			$result['timestamp'] = 1;
		}
		else
		{*/
		if(!empty($this->request->data))
		{
			$result = $res = array();
			if(isset($this->request->data['user_id']))
				$user_id = $this->request->data['user_id'];
			else
				$user_id='';
		
			$this->loadModel('Category');
			$this->loadModel('Like');

			$subcat = $this->Category->find('all', array('fields' => array('id','title','img','like_unlike_status'), 'order' => 'Category.title asc','conditions' => array('status' => 1)));
			$i = 0;
			foreach($subcat as $cat){
				//$logo = ($cat['Category']['logo'] == '' ? '' : ($cat['Category']['logo'] == 'NULL' ? '' : DISPLAY_CATEGORY_DIR.$cat['Category']['logo']));
				$res[$i]['id'] = $cat['Category']['id'];
				$res[$i]['name'] = $cat['Category']['title'];
				
				$status = $this->Like->find('all', array('fields'=>array('like_unlike_status'), 'conditions'=>array('user_id'=>$user_id,'type_id'=>$res[$i]['id'])));
				if(!empty($status))
				{
					foreach ($status as $row) {
						$res[$i]['like_unlike_status'] = $row['Like']['like_unlike_status'];
					}
				}
				else
					$res[$i]['like_unlike_status'] = "0";

				$res[$i]['img'] = DISPLAY_CATEGORY_DIR.$cat['Category']['img'];
				if(!file_exists(UPLOAD_CATEGORY_DIR.'175x175_'.$cat['Category']['img'])){				
					$this->Image->resize_crop_image(175,175, UPLOAD_CATEGORY_DIR.$cat['Category']['img'], UPLOAD_CATEGORY_DIR.'175x175_'.$cat['Category']['img']);
				}
				$res[$i]['image']      = DISPLAY_CATEGORY_DIR.'175x175_'.$cat['Category']['img'];			
				$i++;
			}
			$result['subcategory'] = $res;
			$result['status'] = 1;			
		}
		else
		{
			$result['msg'] =  'Invalid post request';
			$result['status'] = 0;
		}

		$a = json_encode($result);
		echo preg_replace('/[\x00-\x1F\x80-\xFF]/', '', $a);
		exit;
	}
	
	function getAllSubCat()
	{
		#Configure::write('debug',2);
		$this->loadModel('Category');
        $this->loadModel('Mobileapp');
		$subcat = $this->Category->find('all', array('fields' => array('id','title','img','logo'), 'conditions' => array('status' => 1),'order' => 'Category.subcat_order asc'));
		$banners = $this->Mobileapp->find('all', array('fields' => array('id','iphone','ipad','android','store_url'), 'conditions' => array('status' => 1), 'order' => 'Mobileapp.id  desc'));
        $i = 0;
		if(!empty($banners))
		{
			foreach($banners as $banner)
			{				
				$ipad_arr = $banner['Mobileapp']['ipad'];
				$ipad_substr = split ("\.", $ipad_arr);			
				
				$results[$i]['iphone']  = DISPLAY_MOBILE_DIR.'414x156_'.$ipad_arr;	
				$results[$i]['iphone4'] = DISPLAY_MOBILE_DIR.'320x156_'.$ipad_arr;	
				$results[$i]['ipad_']   = DISPLAY_MOBILE_DIR.'736x218_'.$ipad_arr;
				$results[$i]['android'] = DISPLAY_MOBILE_DIR.'360x170_'.$ipad_arr;
				
				if(!file_exists(UPLOAD_MOBILE_DIR.'263x158_'.$ipad_arr)){				
					$this->Image->resize_crop_image(263,158, UPLOAD_MOBILE_DIR.$ipad_arr, UPLOAD_MOBILE_DIR.'263x158_'.$ipad_arr);
				}
							
				if(!file_exists(UPLOAD_MOBILE_DIR.'414x156_'.$ipad_arr)){				
					$this->Image->resize_crop_image(414,156, UPLOAD_MOBILE_DIR.$ipad_arr, UPLOAD_MOBILE_DIR.'414x156_'.$ipad_arr);
				}				
							
				if(!file_exists(UPLOAD_MOBILE_DIR.'320x156_'.$ipad_arr)){				
					$this->Image->resize_crop_image(320,156, UPLOAD_MOBILE_DIR.$ipad_arr, UPLOAD_MOBILE_DIR.'320x156_'.$ipad_arr);
				}			
				if(!file_exists(UPLOAD_MOBILE_DIR.'736x218_'.$ipad_arr)){				
					$this->Image->resize_crop_image(736,218, UPLOAD_MOBILE_DIR.$ipad_arr, UPLOAD_MOBILE_DIR.'736x218_'.$ipad_arr);
				}				
				if(!file_exists(UPLOAD_MOBILE_DIR.'360x170_'.$ipad_arr)){				
					$this->Image->resize_crop_image(360,170, UPLOAD_MOBILE_DIR.$ipad_arr, UPLOAD_MOBILE_DIR.'360x170_'.$ipad_arr);
				}
				
				$results[$i]['androidtab'] = DISPLAY_MOBILE_DIR.'768x218_'.$ipad_arr;				
				if(!file_exists(UPLOAD_MOBILE_DIR.'768x218_'.$ipad_arr)){				
					$this->Image->resize_crop_image(768,218, UPLOAD_MOBILE_DIR.$ipad_arr, UPLOAD_MOBILE_DIR.'768x218_'.$ipad_arr);
				}
				
				$results[$i]['store_id'] = $banner['Mobileapp']['store_url'];
				$i++;
			}
		}
		else 
		{
			echo " ";
		}
        $i = 0;
		foreach($subcat as $cat)
		{
			$logo = ($cat['Category']['logo'] == '' ? '' : ($cat['Category']['logo'] == 'NULL' ? '' : DISPLAY_CATEGORY_DIR.$cat['Category']['logo']));
			$res[$i]['id'] 	 = $cat['Category']['id'];
			$res[$i]['name'] = $cat['Category']['title'];
			$res[$i]['image'] = DISPLAY_CATEGORY_DIR.$cat['Category']['img'];
			$res[$i]['logo'] = $logo;
			$i++;
		}
                
        $result['banners'] = $results;
		$result['subcategory'] = $res;
		$result['timestamp'] = 1;			
		
		echo json_encode($result);
		exit;
	}
	
	function deleteReview()
	{
		$result = array();		
		if(!empty($this->request->data))
		{
			$data = $this->request->data;
			$this->loadModel('Review');
			$this->Review->delete($data['id']);
			$result['msg'] =  'Your Review has been deleted successfully.';
			$result['status'] = 1;
		}
		else
		{
			$result['msg'] =  'Invalid post request';
			$result['status'] = 0;
		}
		echo json_encode($result);
		exit;
	}
	
	function writeReview()
	{
		 $result = array();		
		if(!empty($this->request->data))
		{
			$data = $this->request->data;
			$this->loadModel('Review');
			$review = $this->Review->find('first', array('conditions' => array('ref_id' => $data['ref_id'], 'user_id' => $data['user_id'], 'type' => 'outlet')));
			if(count($review) > 0 && $data['review'] != ''){
				$this->Review->delete($review['Review']['id']);
			}
			else if(count($review) > 0)
			{
				$data['review']      = $review['Review']['review'];
				$data['device_type'] = $this->request->data['deviceType'];
				$this->Review->id = $review['Review']['id'];
			}
			$this->Review->save($data);
			$result['msg'] =  'Your Review has been submitted successfully. Waiting for approval!';
			$result['status'] = 1;
		}
		else
		{
			$result['msg'] =  'Invalid post request';
			$result['status'] = 0;
		}
		echo json_encode($result);
		exit;		
	}
	
	function locationSearch()
	{		
		$res_arr = $result = array();		
		if(!empty($this->request->data))
		{
			$this->loadModel('City');
            $loc = $this->request->data['location'];            
            //$query = 'SELECT l.title, c.title as city,s.title as state FROM cities c  join states s ON (s.id = c.state_id) join landmarks l ON (s.id = l.state_id)   where l.title like '."'%$loc%'".' or c.title like '."'%$loc%'".' or s.title like '."'%$loc%'".' group by c.title order by s.title asc limit 50';
            $query = 'SELECT c.title as city,s.title as state FROM cities c join states s ON (s.id = c.state_id)  where c.title like '."'%$loc%'".' or s.title like '."'%$loc%'".' group by c.title order by s.title asc';
            $res = $this->City->query($query);
            $loc = array();$i=0;
           if(count($res) > 0){
			    foreach($res as $k => $v){
				   $loc[$i]['name']= $v['c']['city'].', '.$v['s']['state'];
				   $i++;
               }
               $result['location'] =  $loc;
			   $result['status'] = 1;
            }
            else
            {
				$result['msg'] =  'No record found.';
				$result['status'] = 0;
			}             
		}
		else
		{
			$result['msg'] =  'Invalid post request';
			$result['status'] = 0;
		}
		echo json_encode($result);
		exit;	
	}
	
	function search()
	{ 
		Configure::write('debug',2);
		$res_arr = $result = array();
		$result['success'] = 0;
		if(!empty($this->request->data))
		{
			$reqData = $this->request->data;
			$address = $this->request->data['location']	;
			$geo = file_get_contents('http://maps.googleapis.com/maps/api/geocode/json?address='.urlencode($address).'&sensor=false');
			$geo = json_decode($geo, true);
			$data = explode(',', trim($address));
			$loc = $data[0];
			
			/*$ARR_STATES = Configure::read('ARR_STATES');			 
			$state = array_search(trim($data[1]), $ARR_STATES);
			$this->loadModel('City');
			$city = $this->City->field('id', array('title like' => '%'.$data[0].'%'));
			*/
			$km = '< 50';
			if ($geo['status'] = 'OK') {								
				$latitude = $geo['results'][0]['geometry']['location']['lat'];
				$longitude = $geo['results'][0]['geometry']['location']['lng'];
				$this->loadModel('Outlet');
				$cond_arr = array('Outlet.status' => 1);
				$add_feat_cond = '';
				$ord_by = 'distance_ asc';
				if(!empty($this->request->data['filter']))
				{
					if($this->request->data['filter'] == 'rating'){
						$ord_by = 'avg_rating desc';
					}				
				}
				if(isset($this->request->data['upto']) && !empty($this->request->data['upto']))
				{
					$km = '> '.$this->request->data['upto'];			
				}			
				$group_by = 'Outlet.id';
				$add_fields = array();
				if(!empty($this->request->data['cat_name']))
				{
					$cat_name = $this->request->data['cat_name'];
					$data = $this->Outlet->query('select id from parcategory where name like "%'.$cat_name.'%"');
					if(count($data) > 0){
						$this->request->data['cat_id'] = $data[0]['parcategory']['id'];
					}									
				}				
				if(!empty($this->request->data['cat_id']))
				{
					$cond_arr[] = 'find_in_set('.$this->request->data['cat_id'].', Outlet.category_parent_id)';
					$add_feat_cond .= ' and OutletFeatured.category_parent_id = '.$this->request->data['cat_id'];
				}
				else
				{
					$add_feat_cond .= ' and OutletFeatured.category_parent_id is null';
				}	
				if(isset($reqData['keyword']) && !empty($reqData['keyword']))
				{
						$q = trim($reqData['keyword']);
						$cond_arr[] = array('or' => array('Outlet.title like' => '%'.$q.'%', 'OutletName.title like' => '%'.$q.'%', 'Outlet.description like' => '%'.$q.'%', 'find_in_set("'.$q.'", `Outlet`.tags)'));
				}
				$joins = array(
					array(
						'table' => 'cities',
						'alias' => 'City',
						'type' => 'left',
						'conditions' => array('City.id = Outlet.city')
					),
					array(
						'table' => 'outlet_names', 
						'alias' => 'OutletName',
						'type' => 'left',
						'conditions' => array('OutletName.id = Outlet.outlet_name_id')
					),
					array(
						'table' => 'filerecs',
						'alias' => 'Filerec',
						'type' => 'left',
						'conditions' => array('Outlet.id = Filerec.ref_id and Filerec.ref_type=1')
						),					
					array(
						'table' => 'parcategory', 
						'alias' => 'OutletType',
						'type' => 'left',
						'conditions' => array('OutletType.id = Outlet.category_parent_id')
					)
					);
					if(!empty($this->request->data['sub_cat_id']))
					{
						$joins[] = array('table' => 'categories_outlets', 'alias' => 'CategoriesOutlet', 'type' => 'left', 'conditions' => array('CategoriesOutlet.outlet_id = Outlet.id'));
						$cond_arr['CategoriesOutlet.category_id'] = $this->request->data['sub_cat_id'];
						$add_feat_cond .= ' and OutletFeatured.category_id = '.$this->request->data['sub_cat_id'];
					}
					else
					{
						$add_feat_cond .= ' and OutletFeatured.category_id is null';
					}
					
					$joins[] = array(
					'table' => 'outlet_featureds', 
					'alias' => 'OutletFeatured',
					'type' => 'left',
					'conditions' => array('OutletFeatured.ftype=3 and OutletFeatured.outlet_id = Outlet.id')
					);
				
					if(!empty($this->request->data['user_id']))
					{
						$joins[] = array(
								'table' => 'likes',
								'alias' => 'Bookmark',
								'type' => 'left',
								'conditions' => array('Bookmark.ref_id = Outlet.id', 'Bookmark.user_id' => $this->request->data['user_id'], 'Bookmark.ref_type' => '1', 'Bookmark.type' => 'bookmark')
							);						
						$add_fields = array('Bookmark.id');
					}
					$offset = '';
					if(!empty($this->request->data['page']))
					{
						$offset = $this->request->data['page'];
					}
					$user_lat  = $this->request->data['user_lat'];
					$user_long = $this->request->data['user_long'];
					$arrCon = array(
							'fields' => array_merge(array('Outlet.id','round(((acos(sin(('.$user_lat.'*pi()/180)) * 
										sin((lat*pi()/180))+cos(('.$user_lat.'*pi()/180)) *
										cos((lat*pi()/180)) * cos((('.$user_long.'-lng)* 
										pi()/180))))*180/pi())*60*1.1515,2) as distance_',
										'(3959 * acos(cos(radians('.$latitude.'))* cos(radians(Outlet.lat)) * cos(radians(Outlet.lng) - radians('.$longitude.')) + sin(radians('.$latitude.')) * sin(radians(lat)))) as distance','banner','lat','lng','OutletType.name','Outlet.mem_type', 'Outlet.title', 'Outlet.address', 'Outlet.phone_no', 'Outlet.personal_mob_no','Outlet.phone_no2','OutletName.title', 'OutletName.logo', 'City.title', 'Filerec.file_name', "IFNULL(OutletFeatured.id, 0) as feat_sort", 'OutletFeatured.id', '(select avg(Review.rating) from reviews as `Review` where `Review`.ref_id = Outlet.id and `Review`.type = "outlet" and `Review`.status = 1) as avg_rating'), $add_fields),
							'joins' => $joins, 
							'conditions' => $cond_arr, 
							//'group' => $group_by, 
							'order' => $ord_by, 							
							'group' => 'Outlet.id having distance '.$km,
							'offset' =>  (!empty($offset)?(($offset - 1) * 20):0),
							'limit' => 20,
						);
				
					//$result_out = $this->paginate('Outlet');	
					$result_out = $this->Outlet->find('all',$arrCon);
					
					if(	count($result_out) > 0){
						 $arr = $featured_arry = array();
						 $i = $j = 0;
						foreach($result_out as $k){
							
							$lat1 = (isset($reqData['user_lat']) && $reqData['user_lat'] != 0 ? $reqData['user_lat'] : $latitude);
							$lon1 = (isset($reqData['user_long']) && $reqData['user_long'] != 0 ? $reqData['user_long'] : $longitude);							
							$lat2 = $k['Outlet']['lat']; 
							$lon2 = $k['Outlet']['lng'];							
							$img_name 				= $k['Filerec']['file_name'];
							$dotpos 				= strrpos($img_name, '.');
							$firstpart 			    = substr($img_name, 0, $dotpos);
							$ext 					= substr($img_name, ($dotpos+1));
							$arr[$i]['id'] 			= $k['Outlet']['id'];
							$arr[$i]['name'] 		= $k['Outlet']['title'];
							$arr[$i]['market_type'] = ($k['OutletType']['name'] == null ? '' : $k['OutletType']['name']);
							$arr[$i]['bookmark']    = (isset($k['Bookmark']['id']) ? ($k['Bookmark']['id'] != '' ? 'yes' : 'no') : 'no') ;
							$arr[$i]['rating']		= number_format((float)$k['0']['avg_rating'], 2, '.', '');
							$arr[$i]['phone_no']	= ($k['Outlet']['phone_no'] != '' ? $k['Outlet']['phone_no'] : '').($k['Outlet']['phone_no2'] != '' ? ' ,'.$k['Outlet']['phone_no2'] : '').($k['Outlet']['personal_mob_no'] != '' ? ' ,'.$k['Outlet']['personal_mob_no'] : '');
							$arr[$i]['location']	= ($k['City']['title'] != '' ? $k['City']['title'] : '');							
							$arr[$i]['user_lat']    =  $lat1;
							$arr[$i]['lat']         =  $lat2;
							$arr[$i]['long']        =  $lon2;
							$arr[$i]['user_long']   =  $lon1;
							$arr[$i]['distance']   =  $k[0]['distance_'];
							$arr[$i]['distance']    = number_format((float)$this->distance($lat1, $lon1, $lat2, $lon2, 'K'), 2, '.','');								
							$img_name = $image_ipad = $featuredImg = '';
							if($k['Outlet']['banner'] != '' )
							{
							    $img_name = DISPLAY_OUTLET_DIR.'129x117_'.$k['Outlet']['banner'];
								$image_ipad = DISPLAY_OUTLET_DIR.'156x131_'.$k['Outlet']['banner'];
								$featuredImg = DISPLAY_OUTLET_DIR.'268x101_'.$k['Outlet']['banner'];
								
								if(!file_exists(UPLOAD_OUTLET_DIR.'156x131_'.$k['Outlet']['banner'])){				
									$this->Image->resize_crop_image(156,131, UPLOAD_OUTLET_DIR.$k['Outlet']['banner'], UPLOAD_OUTLET_DIR.'156x131_'.$k['Outlet']['banner']);
								}
								if(!file_exists(UPLOAD_OUTLET_DIR.'129x117_'.$k['Outlet']['banner'])){				
									$this->Image->resize_crop_image(129,117, UPLOAD_OUTLET_DIR.$k['Outlet']['banner'], UPLOAD_OUTLET_DIR.'129x117_'.$k['Outlet']['banner']);
								}
								if(!file_exists(UPLOAD_OUTLET_DIR.'268x101_'.$k['Outlet']['banner'])){				
									$this->Image->resize_crop_image(268,101, UPLOAD_OUTLET_DIR.$k['Outlet']['banner'], UPLOAD_OUTLET_DIR.'268x101_'.$k['Outlet']['banner']);
								}								
							}	
							
							$arr[$i]['image_ipad']	= $image_ipad;							
							$arr[$i]['image']		= $img_name;
							if($k['OutletFeatured']['id'] !=  null){
								$featured_arry[$j]['id'] = $k['Outlet']['id'];
								$featured_arry[$j]['name'] = $k['Outlet']['title'];
								$featured_arry[$j]['outlet_featured'] = $featuredImg;
								$j++;
							}
							$i++;
						}
						
						/*$arr1 = $arr2 = array();
						$i = $j = 0;
						foreach($arr as $k)
						{
							if(strstr($k['location'],$loc)){
								$arr1[] = $k;
								$j++;
							}
							else{
								$arr2[] = $k;
								$i++;
							}							
						}	*/
						//$arr = Set::sort($arr, '{n}.distance_', 'asc');					
						//$arr1 = Set::sort($arr1, '{n}.distance', 'asc');					
						//$arr2 = Set::sort($arr2, '{n}.distance', 'asc');					
						$result['success'] = 1;
						$result['result'] = $arr;//array_merge($arr1,$arr2);
						$result['featured'] = $featured_arry;
					}
					else
					{
					 $result['msg'] = 'No record found';
					}				
				}
				else
				{
					$result['msg'] = 'No record found';
				}
		}
		echo json_encode($result);
		exit;
	}
	
	function forgotPassword() 
	{	
		$res_arr = $result = array();
		$result['success'] = 0;
		$error_flag = true;
		if(!empty($this->request->data))
		{
				$this->loadModel('User');
				$user_det = $this->User->find('first', array('conditions' => array('User.email' => $this->request->data['email'])));
				if(empty($user_det))
				{
					$result['success'] = 0;
					$result['msg']     = 'Email doesn\'t exists';
				}
				else
				{
					$row = $user_det['User'];
					$error_flag = false;
				}
				
				if(!$error_flag)
				{
					$ver_code = $this->Auth->password(uniqid());
					
					//UPDATING THE PASSWORD VERIFICATION CODE AND THE TIMESTAMP..
					$this->User->id = $row['id'];
					$data_arr['User']['password_verification_code'] = $ver_code;
					$data_arr['User']['new_password_tstamp'] = time();
					$this->User->save($data_arr);

					$new_password_link = SITE_URL.'user/setnew_password/v:'.$ver_code;
					
					//SENDING MAIL WITH NEW PASSWORD
					$this->loadModel('EmailTemplate');

					$srch_array = array("{{username}}" => ucwords($row['display_name']), "{{new_password_link}}" => $new_password_link);
					
					$email_values = $this->EmailTemplate->getvalues('forgot_password', $srch_array);
					
					$this->Email->from = $email_values['from_name'].' <'.$email_values['from_emailid'].'>';
					$this->Email->to = $row['email'];
					$this->Email->subject = $email_values['subject'];
					$this->Email->sendAs = 'html';
					$this->Email->smtpOptions = Configure::read('EMAIL_CONFIG');
					$this->Email->delivery = EMAIL_DELIVERY;
					$this->Email->send($email_values['content']);
					$result['success'] = 1;				
					$result['msg'] 	  = 'An email has been sent on email address';						
				}			
		}
		else
		{
			$result['success'] = 0;				
			$result['msg'] = 'Invalid request';	
		}
		echo json_encode($result);
		exit;
	}
	
	function outletNameSearch()
	{
		$res_arr = $result = array();
		$result['success'] = 0;
		if(!empty($this->request->data))
		{
			$reqData = $this->request->data;
			$address = $this->request->data['location']	;
			/*$geo = file_get_contents('http://maps.googleapis.com/maps/api/geocode/json?address='.urlencode($address).'&sensor=false');
			$geo = json_decode($geo, true);			
			if ($geo['status'] = 'OK') {			
				$latitude = $geo['results'][0]['geometry']['location']['lat'];
				$longitude = $geo['results'][0]['geometry']['location']['lng'];*/
				$this->loadModel('Outlet');
				$cond_arr = array('Outlet.status' => 1);
				$add_feat_cond = '';
				$ord_by = 'Outlet.id desc';
				$group_by = 'Outlet.id';
				$add_fields = array();
				if(!empty($this->request->data['keyword']))
				{
					$cat_name = $this->request->data['keyword'];
					$data = $this->Outlet->query('select id from parcategory where name like "%'.$cat_name.'%"');
					if(count($data) > 0){
						$this->request->data['cat_id'] = $data[0]['parcategory']['id'];
						$cond_arr[] = 'find_in_set('.$this->request->data['cat_id'].', Outlet.category_parent_id)';
					}					
				}
					//$cond_arr[] ='(3959 * acos(cos(radians('.$latitude.'))* cos(radians(Outlet.lat)) * cos(radians(Outlet.lng) - radians('.$longitude.')) + sin(radians('.$latitude.')) * sin(radians(lat)))) < "20"';
					if(isset($reqData['keyword']) && !empty($reqData['keyword']))
					{
						$q = $reqData['keyword'];
						$cond_arr[] = array('or' => array('Outlet.title like' => '%'.$q.'%', 'OutletName.title like' => '%'.$q.'%', 'Outlet.description like' => '%'.$q.'%', 'find_in_set("'.$q.'", `Outlet`.tags)'));
					}
					
					$offset = 0;
					if(!empty($this->request->data['page']))
					{
						$offset = ($this->request->data['page'] <= 0 ? 0 : $this->request->data['page'] - 1);
					}
					$joins = array(					
						array(
							'table' => 'outlet_names', 
							'alias' => 'OutletName',
							'type' => 'left',
							'conditions' => array('OutletName.id = Outlet.outlet_name_id')
						));				
					$this->paginate = array(
							'fields' => array('Outlet.id','Outlet.title'),							
							'conditions' => $cond_arr, 
							'joins' => $joins,
							'group' => $group_by, 
							'order' => $ord_by, 
							'limit' => 20,
							'offset' => $offset
						);

					$result_out = $this->paginate('Outlet');				
					if(	count($result_out) > 0){
						 $arr = $featured_arry = array();
						 $i = 0;
						foreach($result_out as $k)
						{
							$arr[$i]['id'] 			= $k['Outlet']['id'];
							$arr[$i]['name'] 		= $k['Outlet']['title'];							
							$i++;
						}
						$result['success'] = 1;
						$result['result'] = $arr;						
					}
					else
					{
					 $result['msg'] = 'No record found';
					}				
				
		}
		echo json_encode($result);
		exit;
	}
	
	function distance($lat1, $lon1, $lat2, $lon2, $unit)
	{
		$theta = $lon1 - $lon2;
		$dist = sin(@deg2rad($lat1)) * sin(@deg2rad($lat2)) +  cos(@deg2rad($lat1)) * cos(@deg2rad($lat2)) * cos(@deg2rad($theta));
		$dist = acos($dist);
		$dist = rad2deg($dist);
		$miles = $dist * 60 * 1.1515;
		$unit = strtoupper($unit);

		if ($unit == "K") {
			return ($miles * 1.609344);
		} else if ($unit == "N") {
			return ($miles * 0.8684);
		} else {
			return $miles;
		}
	}
	
	function phoneClick()
	{
		$id = $this->request->data['outlet_id'];
		$this->loadModel('Analytic');
		$this->loadModel('Outlet');
		$data['Analytic']['device_type'] = $this->request->data['deviceType'];
		$data['Analytic']['type']      = 'phone_click';
		$data['Analytic']['ref_id']    = $id;
		$data['Analytic']['item_type'] = 'outlet';
		$this->Analytic->save($data);
		$this->Outlet->updateAll(array('phone_click' => 'phone_click+1'),array('id' => $id));
		die;
	}
	
	/*function outletdetail()
	{		
		//Configure::write('debug',2);
		$address = $this->request->data['location'];
		$id = $this->request->data['outlet_id'];		
		$reqData = $this->request->data;		
		$latitude = $longitude = ''; 
		$geo = file_get_contents('http://maps.googleapis.com/maps/api/geocode/json?address='.urlencode($address).'&sensor=false');
		$geo = json_decode($geo, true);			
		if ($geo['status'] = 'OK') {			
			$latitude = $geo['results'][0]['geometry']['location']['lat'];
			$longitude = $geo['results'][0]['geometry']['location']['lng'];
		}		
		$this->loadModel('Outlet');
		$this->loadModel('Like');
		$error_flag = false;
		$loginuser_flag = false;
		$view_error_title = "Error";
		$view_error_msg = "Sorry outlet not found.";
		
		$cond_arr    = array('Outlet.id' => $id);
		$data = array();
		if(isset($reqData['deviceType'])){
			$data['Analytic']['device_type'] = $reqData['deviceType'];
		}
		
		$this->loadModel('Analytic');        
		$data['Analytic']['type']      = 'views';
		$data['Analytic']['ref_id']    = $id;
		$data['Analytic']['item_type'] = 'outlet';
		$this->Analytic->save($data);
		$this->Outlet->updateAll(array('viewed' => 'viewed+1'),array('id' => $id));
		
		if(isset($this->request->data['user_id']) && $this->request->data['user_id']!= '')
		{
			$uid = $this->request->data['user_id'];
		}		
		$join = array(
					array(
						'table' => 'outlet_names', 
						'alias' => 'Name',
						'type' => 'left',
						'conditions' => array('Name.id = Outlet.outlet_name_id')
					),
					array(
						'table' => 'cities', 
						'alias' => 'City',
						'type' => 'left',
						'conditions' => array('City.id = Outlet.city')
					),
					array(
						'table' => 'landmarks', 
						'alias' => 'Landmark',
						'type' => 'left',
						'conditions' => array('Landmark.id = Outlet.landmark_id')
					),
					array(
						'table' => 'parcategory', 
						'alias' => 'OutletType',
						'type' => 'left',
						'conditions' => array('OutletType.id = Outlet.category_parent_id')
					),					
			);
			
		$fields = 'Outlet.*,OutletType.name,Outlet.mem_type,Landmark.title,City.title,Name.deal,Name.logo as outlet_logo,Name.title as outlet_name, (select count(Like.id) from likes as `Like` where `Like`.ref_id = Outlet.id and `Like`.ref_type = "1" and `Like`.type = "like") as num_likes, (select avg(Review.rating) from reviews as `Review` where `Review`.ref_id = Outlet.id and `Review`.type = "outlet" and `Review`.status = 1) as avg_rating, (select count(1) from reviews as `Review` where `Review`.ref_id = Outlet.id and `Review`.type = "outlet" and `Review`.status = 1) as num_reviews';
		if(isset($uid) && !empty($uid))
		{
			array_push($join,array(
						'table' => 'likes', 
						'alias' => 'Bookmark',
						'type' => 'left',
						'conditions' => array("Bookmark.ref_id = $id and Bookmark.ref_type=1 and Bookmark.type='bookmark' and Bookmark.user_id = $uid")
					));
			
			array_push($join,array(
						'table' => 'likes', 
						'alias' => 'Checkin',
						'type' => 'left',
						'conditions' => array("Checkin.ref_id = $id and Checkin.ref_type=1 and Checkin.type='checkin' and Checkin.user_id = $uid")
					));
			
			array_push($join,array(
						'table' => 'likes', 
						'alias' => 'Like',
						'type' => 'left',
						'conditions' => array("Like.ref_id = ".$id." and Like.ref_type=1 and Like.type='like' and Like.user_id = $uid")
					));
		  $fields .= ', Bookmark.id, Like.id, Checkin.id';
	   }
        
	   				
		$this->Outlet->bindModel(array(
				'hasMany' => array(
					'Filerec' => array(
						'foreignKey' => 'ref_id',
						'conditions' => array('Filerec.ref_type=1')                                            
					),
				   'Offer'						
				)
			));	
		$this->Outlet->recursive = 1;	
		$result_outlet = $this->Outlet->find('first', array(
							'fields' => array($fields),
							'joins' => $join,
							'conditions' => $cond_arr,
							'order' => array('Outlet.id' => 'desc'), //string or array defining order
						)
					);
			
		if(!empty($result_outlet))
		{
			//FETCH REVIEW
			$this->LoadModel('Review');
			$this->Review->bindModel(array(
									'belongsTo'  => array(
											'User' => array(
													'fields' => array('User.id,User.display_name,profile_img'),
													'conditions' => array('Review.user_id=User.id')													
												)
											)
										)
									);
			
			$joins_review = array();
			$add_fields_review = array();
			if(isset($uid) && !empty($uid))
			{
				$joins_review = array(array(
							'table' => 'likes', 
							'alias' => 'Like',
							'type' => 'left',
							'conditions' => array("Like.ref_id = Review.id and Like.ref_type=2 and Like.type='like' and Like.user_id = ".$uid)
						));
				$add_fields_review[] = 'Like.id';
			}
			
			$result_review = $this->Review->find('all', array('fields' => array_merge(array('Review.*', 'User.id', 'User.display_name', 'User.profile_img', '(select count(Like.id) from likes as `Like` where `Like`.ref_id = Review.id and `Like`.ref_type = "2" and `Like`.type = "like") as num_likes'), $add_fields_review), 'limit' => 1,'joins' => $joins_review, 'conditions' => array('Review.ref_id' => $id, 'Review.type' => 'outlet', 'Review.status' => 1, 'Review.review !=' => ''), 'order' => array('Review.id' => 'desc')));
			$arr_sub_cat = array();
			if(!empty($result_outlet['Category']))
			{
				foreach($result_outlet['Category'] as $row_cat)
				{
					$arr_sub_cat[] = $row_cat['id'];
				}
			}
			
			//FETCH SPONSORED OUTLET
			$result_soutlet = $this->Outlet->get_sponsored_suggest(3, $result_outlet['Outlet']['city'], $result_outlet['Outlet']['state'], $result_outlet['Outlet']['category_parent_id'], $arr_sub_cat, array('Outlet.id !=' => $result_outlet['Outlet']['id']), 2);
			
			//FETCH SUGGESTED OUTLET
			$result_sgoutlet = $this->Outlet->get_sponsored_suggest(4, $result_outlet['Outlet']['city'], $result_outlet['Outlet']['state'], $result_outlet['Outlet']['category_parent_id'], $arr_sub_cat, array('Outlet.id !=' => $result_outlet['Outlet']['id']), 6);
			$likesdata = '';
			if(!empty($uid))
			{
				$row_user_review = $this->Review->find('first', array('conditions' => array('Review.user_id' => $uid, 'Review.ref_id' => $result_outlet['Outlet']['id'],'Review.status' => 1,'Review.type' => 'outlet')));
				$likesdata = $this->Like->find('count', array('conditions' => array('Like.user_id'=>$uid,'Like.ref_type' => 1,'Like.ref_id' => $id,'Like.type' => 'like')));  
			}
			$likecount = $this->Like->find('count', array('conditions' => array('Like.ref_type' => 1,'Like.ref_id' => $id,'Like.type' => 'like')));  
			
			$num_reviews_withmes = $this->Review->find('count', array('conditions' => array('Review.ref_id' => $result_outlet['Outlet']['id'], 'Review.type' => 'outlet', 'Review.status' => 1, 'Review.review !=' => '')));
			//$lat1 = $latitude; $lon1 = $longitude; $lat2 = $result_outlet['Outlet']['lat']; $lon2 = $result_outlet['Outlet']['lng'];							
			$k = $result_outlet;
			$lat1 = (isset($reqData['user_lat']) && $reqData['user_lat'] != 0 ? $reqData['user_lat'] : $latitude);
			$lon1 = (isset($reqData['user_long']) && $reqData['user_long'] != 0 ? $reqData['user_long'] : $longitude);							
							
			$lat2 = $k['Outlet']['lat'];
			$lon2 = $k['Outlet']['lng'];
			if($k['Outlet']['banner'] != '')
			{
				if(!file_exists(UPLOAD_CATEGORY_DIR.'768x205_'.$k['Outlet']['banner'])){				
						$this->Image->resize_crop_image(768,205, UPLOAD_OUTLET_DIR.$k['Outlet']['banner'], UPLOAD_OUTLET_DIR.'768x205_'.$k['Outlet']['banner']);
				}
				if(!file_exists(UPLOAD_CATEGORY_DIR.'414x205_'.$k['Outlet']['banner'])){				
					$this->Image->resize_crop_image(414,205, UPLOAD_OUTLET_DIR.$k['Outlet']['banner'], UPLOAD_OUTLET_DIR.'414x205_'.$k['Outlet']['banner']);
				}
				if(!file_exists(UPLOAD_CATEGORY_DIR.'320x205_'.$k['Outlet']['banner'])){				
					$this->Image->resize_crop_image(320,205, UPLOAD_OUTLET_DIR.$k['Outlet']['banner'], UPLOAD_OUTLET_DIR.'320x205_'.$k['Outlet']['banner']);
				} 
			}
			$numbers = $comma = $comma1= '';
			if($k['Outlet']['personal_mob_no'] != '' ){$numbers .= $k['Outlet']['personal_mob_no'];$comma = ',';}
			if($k['Outlet']['phone_no'] != '' ){$numbers .= $comma.$k['Outlet']['phone_no']; $comma1 = ',';}
			if($k['Outlet']['phone_no2'] != '' ){$numbers .= $comma1.$k['Outlet']['phone_no2'];}
			
			($k['Outlet']['phone_no'] != '' ? $k['Outlet']['phone_no'] : '').($k['Outlet']['phone_no2'] != '' ? ' ,'.$k['Outlet']['phone_no2'] : '');			
			$state = Configure::read('ARR_STATES');
			$state = $state[$k['Outlet']['state']];
			$landmark = $k['Landmark']['title'];
			$arr['id'] 			= $k['Outlet']['id'];
			$arr['name'] 		= $k['Outlet']['title'];
			$arr['currency_accepted'] = ($k['Outlet']['currency_accepted'] == null ? '' : $k['Outlet']['currency_accepted']);
			$arr['market_type'] = ($k['OutletType']['name'] == null ? '' : $k['OutletType']['name']);
			$arr['bookmark']    = (isset($k['Bookmark']['id']) ? ($k['Bookmark']['id'] != '' ? 'yes' : 'no') : 'no') ;
			$arr['rating']		= number_format((float)$k['0']['avg_rating'], 2, '.', '');
			$arr['phone_no']	= $numbers;
			$arr['full_location']	= ($k['Outlet']['building_no'] != '' ? $k['Outlet']['building_no'].', ' : '').($k['Outlet']['street'] != '' ? $k['Outlet']['street'].', ' : '').($k['City']['title'] != '' ? $k['City']['title'].', ' : '').($state != '' ? $state.', ' : '').$k['Outlet']['zipcode'];
			$arr['location']	= ($k['City']['title'] != '' ? $k['City']['title'] : '');
			$arr['distance']    = number_format((float)$this->distance($lat1, $lon1, $lat2, $lon2, 'K'), 2, '.','');
			$arr['landmark']    =  ($landmark != '' ? $landmark : '');
			$arr['user_lat']    =  $lat1;
			$arr['lat']         =  $lat2;
			$arr['long']        =  $lon2;
			$arr['user_long']   =  $lon1;
			$arr['banner_ipad']		= ($k['Outlet']['banner'] != '' ? DISPLAY_OUTLET_DIR.'768x205_'.$k['Outlet']['banner'] : '');
			$arr['banner_6s']		= ($k['Outlet']['banner'] != '' ? DISPLAY_OUTLET_DIR.'414x205_'.$k['Outlet']['banner'] : '');
			$arr['banner']		= ($k['Outlet']['banner'] != '' ? DISPLAY_OUTLET_DIR.'320x205_'.$k['Outlet']['banner'] : '');
			$arr['reviewcount']	= $num_reviews_withmes;	
			$arr['likecount']	= $likecount;	
			$arr['credit_card'] = ($k['Outlet']['cc_flag'] == 2 ? 'no' : 'yes');
			$arr['delivery'] 	= ($k['Outlet']['delivery'] == 2 ? 'no' : 'yes');
			$arr['like'] 		= ($likesdata == 0 ? 'no' : 'yes');
			$fri = 'Fri';
			$timestamp    = strtotime(date('m/d/Y h:i:s a', time()));
			$today = date('D',$timestamp);
			$opentime 	    = date('h:i A', strtotime($k['Outlet']['open_time']));
			$open_time_brk  = (!empty($k['Outlet']['open_time_brk']) && $k['Outlet']['open_time_brk']!= null ? date('h:i A', strtotime($k['Outlet']['open_time_brk'])) : '');
			$close_time_brk = (!empty($k['Outlet']['close_time_brk']) && $k['Outlet']['close_time_brk'] != null ? date('h:i A', strtotime($k['Outlet']['close_time_brk'])) : '');
			$closetime 		= date('h:i A', strtotime($k['Outlet']['close_time']));
			if($k['Outlet']['timings24'] == 1)
			{ 
				$arr['timings'][0]['open_time']   = '24x7';
				$arr['timings'][0]['close_time']  = '24x7';
				$arr['timings'][0]['name']  	  = 'all';				
				$show = 1;
			}
			else if($k['Outlet']['timings24'] == 2)
			{
				$days = array('Mon','Tue','Wed','Thu','Sat','Sun');
				if($k['Outlet']['fri_open_flag'] == 1)
				{					
					if($k['Outlet']['fri_timings24'] == 1)
					{
						$arr['timings'][0]['open_time']  = '24x7';
						$arr['timings'][0]['close_time']  = '24x7';
						$arr['timings'][0]['name'] = 'Fri';	
						$arr['timings'][0]['current_status'] = 'open';	
					}
					else  
					{
						 $brkopen = $k['Outlet']['fri_open_time_brk'];
						 $brkclose = $k['Outlet']['fri_close_time_brk'];
						 $friopentime    = date('h:i A', strtotime($k['Outlet']['fri_open_time']));
						 $friopentimebrk = (!empty($brkopen) && $brkopen!= null ? date('h:i A', strtotime($brkopen)) : '');
						 $friclosetimebrk = (!empty($brkclose) && $brkclose!= null ? date('h:i A', strtotime($brkclose)) : '');
						 $friclosetime = date('h:i A', strtotime($k['Outlet']['fri_close_time']));
						 $fri = 'Fri';
						 if($friopentimebrk != ''){
							 $arr['timings'][0]['open_time']  = $friopentime.' to '.$friopentimebrk; 
							 $arr['timings'][0]['close_time'] = $friclosetimebrk.' to '.$friclosetime;
							 $arr['timings'][0]['fridayBrkTime'] = 'y';
						}
						else
						{
							 $arr['timings'][0]['open_time']  = $friopentime; 
							 $arr['timings'][0]['close_time'] = $friclosetime;
							 $arr['timings'][0]['fridayBrkTime'] = 'n';
						}	 
						 $arr['timings'][0]['name'] = 'Fri';
					}
				}
				else
				{
						$arr['timings'][0]['open_time']  = 'close';
						$arr['timings'][0]['close_time']  = 'close';
						$arr['timings'][0]['name'] = 'Fri';		
				}				
				
				 $day = date('D', $timestamp);
				 $date = date('m/d/Y h:i:s a', time());
				 $timestmp = strtotime($date);
				 $curr_time = strtotime(date('H:i'));
				 $i = 1;
				 foreach($days as $key=>$val)
				 { 
					 if($open_time_brk == ''){
						 $arr['timings'][$i]['open_time']  = $opentime;
						 $arr['timings'][$i]['close_time'] = $closetime;
						 $arr['timings'][$i]['BrkTime'] = 'n';
					 }
					 else
					 {		
						 $arr['timings'][$i]['open_time']  = $opentime.' to '.$open_time_brk ;
						 $arr['timings'][$i]['close_time'] = $close_time_brk.' to '.$closetime;
						 $arr['timings'][$i]['BrkTime'] = 'y';				
					 }	 
					 $arr['timings'][$i]['name'] 	   = $val;	
					 $i++;				 
				 }			
				 //Today Start	 
				 if($today != $fri){
					 
					 $arr['Today_timings'][0]['open_time']  = ($open_time_brk == '' ? $opentime : $opentime.' to '.$open_time_brk); 
					 $arr['Today_timings'][0]['close_time'] = ($close_time_brk == '' ? $closetime : $close_time_brk.' to '.$closetime);
					 $arr['Today_timings'][0]['BrkTime'] = ($open_time_brk != '' ? 'y' : 'n');
					 $arr['Today_timings'][0]['day'] 		= $today;
					 $closeTime = strtotime($closetime);
					 if(strstr($opentime,'AM') && strstr($closetime,'AM')){
						$closeTime = strtotime(date("Y-m-d h:ia",strtotime($closetime . ' +1 day')));  						
					 }
					 $openTime = strtotime($opentime);
					
					 if($open_time_brk !=''){
						if($curr_time > strtotime($open_time_brk) && $curr_time < strtotime($close_time_brk)){
								$closeTimeBreak = 1;
							}
					}
					if(!isset($closeTimeBreak)){
						$arr['Today_timings'][0]['current_status']	=  ($curr_time >= $openTime && $curr_time <= $closeTime ? 'open' : 'close');
					}else{
						$arr['Today_timings'][0]['current_status']	=  'close';
					}	
					 $arr['Today_timings'][0]['name'] 	  	= 'Today'; 
				 }
				 else
				 {
					 if($k['Outlet']['fri_open_flag'] == 1)
					 {
						$fri = 'Fri';
						if($k['Outlet']['fri_timings24'] == 1)
						{
							$arr['Today_timings'][0]['open_time']  = '24x7';
							$arr['Today_timings'][0]['close_time']  = '24x7';
							$arr['Today_timings'][0]['name'] = 'Fri';
							$arr['Today_timings'][0]['current_status'] = 'open';		
						}
						else  
						{				 
							 $fri = 'Fri';
							 $arr['Today_timings'][0]['open_time']  = ($friopentimebrk == '' ?  $friopentime : $friopentime.' to '.$friopentimebrk); 
							 $arr['Today_timings'][0]['close_time'] = ($friclosetimebrk == '' ? $friclosetime : $friclosetimebrk.' to '.$friclosetime);
							 $arr['Today_timings'][0]['current_status'] =  ($curr_time > strtotime($k['Outlet']['fri_open_time']) && $curr_time < strtotime(date("Y-m-d h:ia",strtotime($k['Outlet']['fri_close_time'] . ' +1 day'))) ? 'open' : 'close');
							 $arr['Today_timings'][0]['BrkTime'] = ($friopentimebrk != '' ? 'y' : 'n');
							 $arr['Today_timings'][0]['name'] = 'Fri';						
						}
					}
					else
					{
							$arr['Today_timings'][0]['open_time']  = 'close';
							$arr['Today_timings'][0]['close_time']  = 'close';
							$arr['Today_timings'][0]['name'] = 'Fri';		
					}
				 }
			}
			if(isset($show))
			{
				 if($today != $fri){
					 
					    $arr['Today_timings'][0]['open_time']  = ($k['Outlet']['timings24'] == 1 ? '24x7' : 'close');
						$arr['Today_timings'][0]['close_time']  = ($k['Outlet']['timings24'] == 1 ? '24x7' : 'close');
						$arr['Today_timings'][0]['current_status'] = ($k['Outlet']['timings24'] == 1 ? 'open' : 'close');
						$arr['Today_timings'][0]['name'] = $today; 
				 }
				 else
				 {
					 if($k['Outlet']['fri_open_flag'] == 1)
					 {
						$fri = 'Fri';
						if($k['Outlet']['fri_timings24'] == 1)
						{
							$arr['Today_timings'][0]['open_time']  = '24x7';
							$arr['Today_timings'][0]['close_time']  = '24x7';
							$arr['Today_timings'][0]['name'] = 'Fri';	
							$arr['Today_timings'][0]['current_status'] = 'open';		
						}
						else  
						{							 
							 $fri = 'Fri';
							 $arr['Today_timings'][0]['open_time']  = ($friopentimebrk == '' ?  $friopentime : $friopentime.' to '.$friopentimebrk); 
							 $arr['Today_timings'][0]['close_time'] = ($friclosetimebrk == '' ? $friclosetime : $friclosetimebrk.' to '.$friclosetime);
							 $arr['Today_timings'][0]['name'] = 'Fri';						
						}
					}
					else
					{
							$arr['Today_timings'][0]['open_time']  = 'close';
							$arr['Today_timings'][0]['close_time']  = 'close';
							$arr['Today_timings'][0]['name'] = 'Fri';		
					}
				 }
			}			
			$this->Review->bindModel(array(
									'belongsTo'  => array(
											'User' => array(
													'fields' => array('User.id,User.address,User.display_name,profile_img'),
													'conditions' => array('Review.user_id=User.id')
												)
											)
										)
									);
			$review = $row_user_review = $this->Review->find('first', array('order' => array('Review.id desc'), 'conditions' => array('Review.review !=' => '','Review.ref_id' => $result_outlet['Outlet']['id'],'Review.type' => 'outlet','Review.status' => 1)));
			$arr['review_details'] = array();
			if(count($review) > 0){
				$arr['review_details']['review'] 	   = $review['Review']['review'];
				$arr['review_details']['rating'] 	   = $review['Review']['rating'];
				$arr['review_details']['created_date'] = $review['Review']['created'];
				$arr['review_details']['current_date'] = date('Y-m-d H:i:s');
				$arr['review_details']['ago'] 		   = formatDateTimeAgoStruct($review['Review']['created']);										
				$arr['review_details']['username']     = $review['User']['display_name'];
				$arr['review_details']['address']      = $review['User']['address'];
				$arr['review_details']['profile_img']  = (!empty($review['User']['profile_img']))? SITE_URL.UPLOAD_USERS_DIR.$review['User']['profile_img'] : 1;
			}
			$i = 0;
			foreach($k['Filerec'] as $file){
					$img_name = $file['file_name'];
					$dotpos 				= strrpos($img_name, '.');
					$firstpart 			    = substr($img_name, 0, $dotpos);
					$ext 					= substr($img_name, ($dotpos+1));
					$arr['photos'][$i] = ($img_name != '' ? SITE_URL.'uploads/outlet/'.$firstpart.'_353x226.'.$ext : '');
					$i++;
			}
			$arr['offers'] = array();
			if(!empty($result_outlet['Offer'])){
				$i=0;
				foreach($result_outlet['Offer'] as $file){
						$img_name = $file['img'];
						$dotpos 				= strrpos($img_name, '.');
						$firstpart 			    = substr($img_name, 0, $dotpos);
						$ext 					= substr($img_name, ($dotpos+1));
						$arr['offers'][$i] = ($img_name != '' ? SITE_URL.'uploads/offer/'.$img_name : '');
						$i++;
				}
			}	
			$result['success'] = 1;
			$result['result'] = $arr;
		}
		else
		{
			$result['success'] = 0;
			$result['result'] = '';			
			$result['msg'] = 'No record found';		
						
		}
		echo json_encode($result);
		exit;
	}*/
	


	/*Store Detail Webservice
	  By - Nikita*/
	function storedetail()
	{

			$result1 = $res = array(); //for store
			$result2 = $res2 = array(); //for deals
					
			$this->loadModel('Category');
			$this->loadModel('Like');
			$this->loadModel('Outlet');
			$this->loadModel('Deal');


			$subcat = $this->Outlet->find('all', array('fields' => array('id','title','category','address','city','state','country','lat','lng','timings','banner','status'), 'order' => 'Outlet.title asc','conditions' => array('status' => 1,'popular_store'=>1)));
			$i = 0;
			foreach($subcat as $cat){
				$res[$i]['id'] = $cat['Outlet']['id'];
				$res[$i]['name'] = $cat['Outlet']['title'];
				$res[$i]['address'] = $cat['Outlet']['address'];
				$res[$i]['city'] = $cat['Outlet']['city'];
				$res[$i]['state'] = $cat['Outlet']['state'];
				$res[$i]['country'] = $cat['Outlet']['country'];
				$res[$i]['lat'] = $cat['Outlet']['lat'];
				$res[$i]['lng'] = $cat['Outlet']['lng'];
				$res[$i]['timings'] = $cat['Outlet']['timings']; 
				$res[$i]['cat_id'] = $cat['Outlet']['category'];
				
				$status = $this->Category->find('all', array('fields'=>array('id','title'), 'conditions'=>array('id'=>$res[$i]['cat_id'])));
					foreach ($status as $row) {
						$res[$i]['category'] = $row['Category']['title'];
					}
				
				$res[$i]['img'] = DISPLAY_OUTLET_DIR.$cat['Outlet']['banner'];
				/*if(!file_exists(UPLOAD_CATEGORY_DIR.'175x175_'.$cat['Category']['img'])){				
					$this->Image->resize_crop_image(175,175, UPLOAD_CATEGORY_DIR.$cat['Category']['img'], UPLOAD_CATEGORY_DIR.'175x175_'.$cat['Category']['img']);
				}
				$res[$i]['image']      = DISPLAY_CATEGORY_DIR.'175x175_'.$cat['Category']['img'];*/			
				$i++;
			}

			
			$deal = $this->Deal->find('all', array('fields' => array('id','deal_name','logo','status'), 'order' => 'Deal.id desc','conditions' => array('popular_deal'=>1,'Deal.status'=>1)));
			$j = 0;
			foreach($deal as $d){
				$res2[$j]['deal_id'] = 'dfsdfsdfds';
				$res2[$j]['deal_id'] = $d['Deal']['id'];
				$res2[$j]['deal_name'] = $d['Deal']['deal_name'];
				$res2[$j]['deal_logo'] = DISPLAY_DEAL_DIR.$d['Deal']['logo'];
				/*if(!file_exists(UPLOAD_CATEGORY_DIR.'175x175_'.$cat['Category']['img'])){				
					$this->Image->resize_crop_image(175,175, UPLOAD_CATEGORY_DIR.$cat['Category']['img'], UPLOAD_CATEGORY_DIR.'175x175_'.$cat['Category']['img']);
				}
				$res[$i]['image']      = DISPLAY_CATEGORY_DIR.'175x175_'.$cat['Category']['img'];*/			
				$j++;
			}

			$result1['store'] = $res;
						
			$result2['deal'] = $res2;
			$result2['status'] = 1;
			
		
		$a1 = json_encode($result1);
		$a = preg_replace('/[\x00-\x1F\x80-\xFF]/', '', $a1);

		$a2 = json_encode($result2);
		$b = preg_replace('/[\x00-\x1F\x80-\xFF]/', '', $a2);

		echo json_encode(array_merge(json_decode($a, true),json_decode($b, true)));
		
		exit;




		//Configure::write('debug',2);
		/*$address = $this->request->data['location'];
		$id = $this->request->data['outlet_id'];		
		$reqData = $this->request->data;		
		$latitude = $longitude = ''; 
		$geo = file_get_contents('http://maps.googleapis.com/maps/api/geocode/json?address='.urlencode($address).'&sensor=false');
		$geo = json_decode($geo, true);			
		if ($geo['status'] = 'OK') {			
			$latitude = $geo['results'][0]['geometry']['location']['lat'];
			$longitude = $geo['results'][0]['geometry']['location']['lng'];
		}		
		$this->loadModel('Outlet');
		$this->loadModel('Like');
		$error_flag = false;
		$loginuser_flag = false;
		$view_error_title = "Error";
		$view_error_msg = "Sorry Store not found.";
		
		$cond_arr    = array('Outlet.id' => $id);
		$data = array();
		if(isset($reqData['deviceType'])){
			$data['Analytic']['device_type'] = $reqData['deviceType'];
		}
		
		$this->loadModel('Analytic');        
		$data['Analytic']['type']      = 'views';
		$data['Analytic']['ref_id']    = $id;
		$data['Analytic']['item_type'] = 'outlet';
		$this->Analytic->save($data);

		$this->Outlet->updateAll(array('viewed' => 'viewed+1'),array('id' => $id));
		
		if(isset($this->request->data['user_id']) && $this->request->data['user_id']!= '')
		{
			$uid = $this->request->data['user_id'];
		}		
		$join = array(
					array(
						'table' => 'outlet_names', 
						'alias' => 'Name',
						'type' => 'left',
						'conditions' => array('Name.id = Outlet.outlet_name_id')
					),
					array(
						'table' => 'cities', 
						'alias' => 'City',
						'type' => 'left',
						'conditions' => array('City.id = Outlet.city')
					),
					array(
						'table' => 'landmarks', 
						'alias' => 'Landmark',
						'type' => 'left',
						'conditions' => array('Landmark.id = Outlet.landmark_id')
					),
					array(
						'table' => 'parcategory', 
						'alias' => 'OutletType',
						'type' => 'left',
						'conditions' => array('OutletType.id = Outlet.category_parent_id')
					),					
			);
			
		$fields = 'Outlet.*,OutletType.name,Outlet.mem_type,Landmark.title,City.title,Name.deal,Name.logo as outlet_logo,Name.title as outlet_name, (select count(Like.id) from likes as `Like` where `Like`.ref_id = Outlet.id and `Like`.ref_type = "1" and `Like`.type = "like") as num_likes, (select avg(Review.rating) from reviews as `Review` where `Review`.ref_id = Outlet.id and `Review`.type = "outlet" and `Review`.status = 1) as avg_rating, (select count(1) from reviews as `Review` where `Review`.ref_id = Outlet.id and `Review`.type = "outlet" and `Review`.status = 1) as num_reviews';
		if(isset($uid) && !empty($uid))
		{
			array_push($join,array(
						'table' => 'likes', 
						'alias' => 'Bookmark',
						'type' => 'left',
						'conditions' => array("Bookmark.ref_id = $id and Bookmark.ref_type=1 and Bookmark.type='bookmark' and Bookmark.user_id = $uid")
					));
			
			array_push($join,array(
						'table' => 'likes', 
						'alias' => 'Checkin',
						'type' => 'left',
						'conditions' => array("Checkin.ref_id = $id and Checkin.ref_type=1 and Checkin.type='checkin' and Checkin.user_id = $uid")
					));
			
			array_push($join,array(
						'table' => 'likes', 
						'alias' => 'Like',
						'type' => 'left',
						'conditions' => array("Like.ref_id = ".$id." and Like.ref_type=1 and Like.type='like' and Like.user_id = $uid")
					));
		  $fields .= ', Bookmark.id, Like.id, Checkin.id';
	   }
        
	   				
		$this->Outlet->bindModel(array(
				'hasMany' => array(
					'Filerec' => array(
						'foreignKey' => 'ref_id',
						'conditions' => array('Filerec.ref_type=1')                                            
					),
				   'Offer'						
				)
			));	
		$this->Outlet->recursive = 1;	
		$result_outlet = $this->Outlet->find('first', array(
							'fields' => array($fields),
							'joins' => $join,
							'conditions' => $cond_arr,
							'order' => array('Outlet.id' => 'desc'), //string or array defining order
						)
					);
			
		if(!empty($result_outlet))
		{
			//FETCH REVIEW
			$this->LoadModel('Review');
			$this->Review->bindModel(array(
									'belongsTo'  => array(
											'User' => array(
													'fields' => array('User.id,User.display_name,profile_img'),
													'conditions' => array('Review.user_id=User.id')													
												)
											)
										)
									);
			
			$joins_review = array();
			$add_fields_review = array();
			if(isset($uid) && !empty($uid))
			{
				$joins_review = array(array(
							'table' => 'likes', 
							'alias' => 'Like',
							'type' => 'left',
							'conditions' => array("Like.ref_id = Review.id and Like.ref_type=2 and Like.type='like' and Like.user_id = ".$uid)
						));
				$add_fields_review[] = 'Like.id';
			}
			
			$result_review = $this->Review->find('all', array('fields' => array_merge(array('Review.*', 'User.id', 'User.display_name', 'User.profile_img', '(select count(Like.id) from likes as `Like` where `Like`.ref_id = Review.id and `Like`.ref_type = "2" and `Like`.type = "like") as num_likes'), $add_fields_review), 'limit' => 1,'joins' => $joins_review, 'conditions' => array('Review.ref_id' => $id, 'Review.type' => 'outlet', 'Review.status' => 1, 'Review.review !=' => ''), 'order' => array('Review.id' => 'desc')));
			$arr_sub_cat = array();
			if(!empty($result_outlet['Category']))
			{
				foreach($result_outlet['Category'] as $row_cat)
				{
					$arr_sub_cat[] = $row_cat['id'];
				}
			}
			
			//FETCH SPONSORED OUTLET
			$result_soutlet = $this->Outlet->get_sponsored_suggest(3, $result_outlet['Outlet']['city'], $result_outlet['Outlet']['state'], $result_outlet['Outlet']['category_parent_id'], $arr_sub_cat, array('Outlet.id !=' => $result_outlet['Outlet']['id']), 2);
			
			//FETCH SUGGESTED OUTLET
			$result_sgoutlet = $this->Outlet->get_sponsored_suggest(4, $result_outlet['Outlet']['city'], $result_outlet['Outlet']['state'], $result_outlet['Outlet']['category_parent_id'], $arr_sub_cat, array('Outlet.id !=' => $result_outlet['Outlet']['id']), 6);
			$likesdata = '';
			if(!empty($uid))
			{
				$row_user_review = $this->Review->find('first', array('conditions' => array('Review.user_id' => $uid, 'Review.ref_id' => $result_outlet['Outlet']['id'],'Review.status' => 1,'Review.type' => 'outlet')));
				$likesdata = $this->Like->find('count', array('conditions' => array('Like.user_id'=>$uid,'Like.ref_type' => 1,'Like.ref_id' => $id,'Like.type' => 'like')));  
			}
			$likecount = $this->Like->find('count', array('conditions' => array('Like.ref_type' => 1,'Like.ref_id' => $id,'Like.type' => 'like')));  
			
			$num_reviews_withmes = $this->Review->find('count', array('conditions' => array('Review.ref_id' => $result_outlet['Outlet']['id'], 'Review.type' => 'outlet', 'Review.status' => 1, 'Review.review !=' => '')));
			//$lat1 = $latitude; $lon1 = $longitude; $lat2 = $result_outlet['Outlet']['lat']; $lon2 = $result_outlet['Outlet']['lng'];							
			$k = $result_outlet;
			$lat1 = (isset($reqData['user_lat']) && $reqData['user_lat'] != 0 ? $reqData['user_lat'] : $latitude);
			$lon1 = (isset($reqData['user_long']) && $reqData['user_long'] != 0 ? $reqData['user_long'] : $longitude);							
							
			$lat2 = $k['Outlet']['lat'];
			$lon2 = $k['Outlet']['lng'];
			if($k['Outlet']['banner'] != '')
			{
				if(!file_exists(UPLOAD_CATEGORY_DIR.'768x205_'.$k['Outlet']['banner'])){				
						$this->Image->resize_crop_image(768,205, UPLOAD_OUTLET_DIR.$k['Outlet']['banner'], UPLOAD_OUTLET_DIR.'768x205_'.$k['Outlet']['banner']);
				}
				if(!file_exists(UPLOAD_CATEGORY_DIR.'414x205_'.$k['Outlet']['banner'])){				
					$this->Image->resize_crop_image(414,205, UPLOAD_OUTLET_DIR.$k['Outlet']['banner'], UPLOAD_OUTLET_DIR.'414x205_'.$k['Outlet']['banner']);
				}
				if(!file_exists(UPLOAD_CATEGORY_DIR.'320x205_'.$k['Outlet']['banner'])){				
					$this->Image->resize_crop_image(320,205, UPLOAD_OUTLET_DIR.$k['Outlet']['banner'], UPLOAD_OUTLET_DIR.'320x205_'.$k['Outlet']['banner']);
				} 
			}
			$numbers = $comma = $comma1= '';
			if($k['Outlet']['personal_mob_no'] != '' ){$numbers .= $k['Outlet']['personal_mob_no'];$comma = ',';}
			if($k['Outlet']['phone_no'] != '' ){$numbers .= $comma.$k['Outlet']['phone_no']; $comma1 = ',';}
			if($k['Outlet']['phone_no2'] != '' ){$numbers .= $comma1.$k['Outlet']['phone_no2'];}
			
			($k['Outlet']['phone_no'] != '' ? $k['Outlet']['phone_no'] : '').($k['Outlet']['phone_no2'] != '' ? ' ,'.$k['Outlet']['phone_no2'] : '');			
			$state = Configure::read('ARR_STATES');
			$state = $state[$k['Outlet']['state']];
			$landmark = $k['Landmark']['title'];
			$arr['id'] 			= $k['Outlet']['id'];
			$arr['name'] 		= $k['Outlet']['title'];
			$arr['currency_accepted'] = ($k['Outlet']['currency_accepted'] == null ? '' : $k['Outlet']['currency_accepted']);
			$arr['market_type'] = ($k['OutletType']['name'] == null ? '' : $k['OutletType']['name']);
			$arr['bookmark']    = (isset($k['Bookmark']['id']) ? ($k['Bookmark']['id'] != '' ? 'yes' : 'no') : 'no') ;
			$arr['rating']		= number_format((float)$k['0']['avg_rating'], 2, '.', '');
			$arr['phone_no']	= $numbers;
			$arr['full_location']	= ($k['Outlet']['building_no'] != '' ? $k['Outlet']['building_no'].', ' : '').($k['Outlet']['street'] != '' ? $k['Outlet']['street'].', ' : '').($k['City']['title'] != '' ? $k['City']['title'].', ' : '').($state != '' ? $state.', ' : '').$k['Outlet']['zipcode'];
			$arr['location']	= ($k['City']['title'] != '' ? $k['City']['title'] : '');
			$arr['distance']    = number_format((float)$this->distance($lat1, $lon1, $lat2, $lon2, 'K'), 2, '.','');
			$arr['landmark']    =  ($landmark != '' ? $landmark : '');
			$arr['user_lat']    =  $lat1;
			$arr['lat']         =  $lat2;
			$arr['long']        =  $lon2;
			$arr['user_long']   =  $lon1;
			$arr['banner_ipad']		= ($k['Outlet']['banner'] != '' ? DISPLAY_OUTLET_DIR.'768x205_'.$k['Outlet']['banner'] : '');
			$arr['banner_6s']		= ($k['Outlet']['banner'] != '' ? DISPLAY_OUTLET_DIR.'414x205_'.$k['Outlet']['banner'] : '');
			$arr['banner']		= ($k['Outlet']['banner'] != '' ? DISPLAY_OUTLET_DIR.'320x205_'.$k['Outlet']['banner'] : '');
			$arr['reviewcount']	= $num_reviews_withmes;	
			$arr['likecount']	= $likecount;	
			$arr['credit_card'] = ($k['Outlet']['cc_flag'] == 2 ? 'no' : 'yes');
			$arr['delivery'] 	= ($k['Outlet']['delivery'] == 2 ? 'no' : 'yes');
			$arr['like'] 		= ($likesdata == 0 ? 'no' : 'yes');
			$fri = 'Fri';
			$timestamp    = strtotime(date('m/d/Y h:i:s a', time()));
			$today = date('D',$timestamp);
			$opentime 	    = date('h:i A', strtotime($k['Outlet']['open_time']));
			$open_time_brk  = (!empty($k['Outlet']['open_time_brk']) && $k['Outlet']['open_time_brk']!= null ? date('h:i A', strtotime($k['Outlet']['open_time_brk'])) : '');
			$close_time_brk = (!empty($k['Outlet']['close_time_brk']) && $k['Outlet']['close_time_brk'] != null ? date('h:i A', strtotime($k['Outlet']['close_time_brk'])) : '');
			$closetime 		= date('h:i A', strtotime($k['Outlet']['close_time']));
			if($k['Outlet']['timings24'] == 1)
			{ 
				$arr['timings'][0]['open_time']   = '24x7';
				$arr['timings'][0]['close_time']  = '24x7';
				$arr['timings'][0]['name']  	  = 'all';				
				$show = 1;
			}
			else if($k['Outlet']['timings24'] == 2)
			{
				$days = array('Mon','Tue','Wed','Thu','Sat','Sun');
				if($k['Outlet']['fri_open_flag'] == 1)
				{					
					if($k['Outlet']['fri_timings24'] == 1)
					{
						$arr['timings'][0]['open_time']  = '24x7';
						$arr['timings'][0]['close_time']  = '24x7';
						$arr['timings'][0]['name'] = 'Fri';	
						$arr['timings'][0]['current_status'] = 'open';	
					}
					else  
					{
						 $brkopen = $k['Outlet']['fri_open_time_brk'];
						 $brkclose = $k['Outlet']['fri_close_time_brk'];
						 $friopentime    = date('h:i A', strtotime($k['Outlet']['fri_open_time']));
						 $friopentimebrk = (!empty($brkopen) && $brkopen!= null ? date('h:i A', strtotime($brkopen)) : '');
						 $friclosetimebrk = (!empty($brkclose) && $brkclose!= null ? date('h:i A', strtotime($brkclose)) : '');
						 $friclosetime = date('h:i A', strtotime($k['Outlet']['fri_close_time']));
						 $fri = 'Fri';
						 if($friopentimebrk != ''){
							 $arr['timings'][0]['open_time']  = $friopentime.' to '.$friopentimebrk; 
							 $arr['timings'][0]['close_time'] = $friclosetimebrk.' to '.$friclosetime;
							 $arr['timings'][0]['fridayBrkTime'] = 'y';
						}
						else
						{
							 $arr['timings'][0]['open_time']  = $friopentime; 
							 $arr['timings'][0]['close_time'] = $friclosetime;
							 $arr['timings'][0]['fridayBrkTime'] = 'n';
						}	 
						 $arr['timings'][0]['name'] = 'Fri';
					}
				}
				else
				{
						$arr['timings'][0]['open_time']  = 'close';
						$arr['timings'][0]['close_time']  = 'close';
						$arr['timings'][0]['name'] = 'Fri';		
				}				
				
				 $day = date('D', $timestamp);
				 $date = date('m/d/Y h:i:s a', time());
				 $timestmp = strtotime($date);
				 $curr_time = strtotime(date('H:i'));
				 $i = 1;
				 foreach($days as $key=>$val)
				 { 
					 if($open_time_brk == ''){
						 $arr['timings'][$i]['open_time']  = $opentime;
						 $arr['timings'][$i]['close_time'] = $closetime;
						 $arr['timings'][$i]['BrkTime'] = 'n';
					 }
					 else
					 {		
						 $arr['timings'][$i]['open_time']  = $opentime.' to '.$open_time_brk ;
						 $arr['timings'][$i]['close_time'] = $close_time_brk.' to '.$closetime;
						 $arr['timings'][$i]['BrkTime'] = 'y';				
					 }	 
					 $arr['timings'][$i]['name'] 	   = $val;	
					 $i++;				 
				 }			
				 //Today Start	 
				 if($today != $fri){
					 
					 $arr['Today_timings'][0]['open_time']  = ($open_time_brk == '' ? $opentime : $opentime.' to '.$open_time_brk); 
					 $arr['Today_timings'][0]['close_time'] = ($close_time_brk == '' ? $closetime : $close_time_brk.' to '.$closetime);
					 $arr['Today_timings'][0]['BrkTime'] = ($open_time_brk != '' ? 'y' : 'n');
					 $arr['Today_timings'][0]['day'] 		= $today;
					 $closeTime = strtotime($closetime);
					 if(strstr($opentime,'AM') && strstr($closetime,'AM')){
						$closeTime = strtotime(date("Y-m-d h:ia",strtotime($closetime . ' +1 day')));  						
					 }
					 $openTime = strtotime($opentime);
					
					 if($open_time_brk !=''){
						if($curr_time > strtotime($open_time_brk) && $curr_time < strtotime($close_time_brk)){
								$closeTimeBreak = 1;
							}
					}
					if(!isset($closeTimeBreak)){
						$arr['Today_timings'][0]['current_status']	=  ($curr_time >= $openTime && $curr_time <= $closeTime ? 'open' : 'close');
					}else{
						$arr['Today_timings'][0]['current_status']	=  'close';
					}	
					 $arr['Today_timings'][0]['name'] 	  	= 'Today'; 
				 }
				 else
				 {
					 if($k['Outlet']['fri_open_flag'] == 1)
					 {
						$fri = 'Fri';
						if($k['Outlet']['fri_timings24'] == 1)
						{
							$arr['Today_timings'][0]['open_time']  = '24x7';
							$arr['Today_timings'][0]['close_time']  = '24x7';
							$arr['Today_timings'][0]['name'] = 'Fri';
							$arr['Today_timings'][0]['current_status'] = 'open';		
						}
						else  
						{				 
							 $fri = 'Fri';
							 $arr['Today_timings'][0]['open_time']  = ($friopentimebrk == '' ?  $friopentime : $friopentime.' to '.$friopentimebrk); 
							 $arr['Today_timings'][0]['close_time'] = ($friclosetimebrk == '' ? $friclosetime : $friclosetimebrk.' to '.$friclosetime);
							 $arr['Today_timings'][0]['current_status'] =  ($curr_time > strtotime($k['Outlet']['fri_open_time']) && $curr_time < strtotime(date("Y-m-d h:ia",strtotime($k['Outlet']['fri_close_time'] . ' +1 day'))) ? 'open' : 'close');
							 $arr['Today_timings'][0]['BrkTime'] = ($friopentimebrk != '' ? 'y' : 'n');
							 $arr['Today_timings'][0]['name'] = 'Fri';						
						}
					}
					else
					{
							$arr['Today_timings'][0]['open_time']  = 'close';
							$arr['Today_timings'][0]['close_time']  = 'close';
							$arr['Today_timings'][0]['name'] = 'Fri';		
					}
				 }
			}
			if(isset($show))
			{
				 if($today != $fri){
					 
					    $arr['Today_timings'][0]['open_time']  = ($k['Outlet']['timings24'] == 1 ? '24x7' : 'close');
						$arr['Today_timings'][0]['close_time']  = ($k['Outlet']['timings24'] == 1 ? '24x7' : 'close');
						$arr['Today_timings'][0]['current_status'] = ($k['Outlet']['timings24'] == 1 ? 'open' : 'close');
						$arr['Today_timings'][0]['name'] = $today; 
				 }
				 else
				 {
					 if($k['Outlet']['fri_open_flag'] == 1)
					 {
						$fri = 'Fri';
						if($k['Outlet']['fri_timings24'] == 1)
						{
							$arr['Today_timings'][0]['open_time']  = '24x7';
							$arr['Today_timings'][0]['close_time']  = '24x7';
							$arr['Today_timings'][0]['name'] = 'Fri';	
							$arr['Today_timings'][0]['current_status'] = 'open';		
						}
						else  
						{							 
							 $fri = 'Fri';
							 $arr['Today_timings'][0]['open_time']  = ($friopentimebrk == '' ?  $friopentime : $friopentime.' to '.$friopentimebrk); 
							 $arr['Today_timings'][0]['close_time'] = ($friclosetimebrk == '' ? $friclosetime : $friclosetimebrk.' to '.$friclosetime);
							 $arr['Today_timings'][0]['name'] = 'Fri';						
						}
					}
					else
					{
							$arr['Today_timings'][0]['open_time']  = 'close';
							$arr['Today_timings'][0]['close_time']  = 'close';
							$arr['Today_timings'][0]['name'] = 'Fri';		
					}
				 }
			}			
			$this->Review->bindModel(array(
									'belongsTo'  => array(
											'User' => array(
													'fields' => array('User.id,User.address,User.display_name,profile_img'),
													'conditions' => array('Review.user_id=User.id')
												)
											)
										)
									);
			$review = $row_user_review = $this->Review->find('first', array('order' => array('Review.id desc'), 'conditions' => array('Review.review !=' => '','Review.ref_id' => $result_outlet['Outlet']['id'],'Review.type' => 'outlet','Review.status' => 1)));
			$arr['review_details'] = array();
			if(count($review) > 0){
				$arr['review_details']['review'] 	   = $review['Review']['review'];
				$arr['review_details']['rating'] 	   = $review['Review']['rating'];
				$arr['review_details']['created_date'] = $review['Review']['created'];
				$arr['review_details']['current_date'] = date('Y-m-d H:i:s');
				$arr['review_details']['ago'] 		   = formatDateTimeAgoStruct($review['Review']['created']);										
				$arr['review_details']['username']     = $review['User']['display_name'];
				$arr['review_details']['address']      = $review['User']['address'];
				$arr['review_details']['profile_img']  = (!empty($review['User']['profile_img']))? SITE_URL.UPLOAD_USERS_DIR.$review['User']['profile_img'] : 1;
			}
			$i = 0;
			foreach($k['Filerec'] as $file){
					$img_name = $file['file_name'];
					$dotpos 				= strrpos($img_name, '.');
					$firstpart 			    = substr($img_name, 0, $dotpos);
					$ext 					= substr($img_name, ($dotpos+1));
					$arr['photos'][$i] = ($img_name != '' ? SITE_URL.'uploads/outlet/'.$firstpart.'_353x226.'.$ext : '');
					$i++;
			}
			$arr['offers'] = array();
			if(!empty($result_outlet['Offer'])){
				$i=0;
				foreach($result_outlet['Offer'] as $file){
						$img_name = $file['img'];
						$dotpos 				= strrpos($img_name, '.');
						$firstpart 			    = substr($img_name, 0, $dotpos);
						$ext 					= substr($img_name, ($dotpos+1));
						$arr['offers'][$i] = ($img_name != '' ? SITE_URL.'uploads/offer/'.$img_name : '');
						$i++;
				}
			}	
			$result['success'] = 1;
			$result['result'] = $arr;
		}
		else
		{
			$result['success'] = 0;
			$result['result'] = '';			
			$result['msg'] = 'No record found';		
						
		}
		echo json_encode($result);
		exit;*/
	}		



	function storedetail2()
	{
			if(isset($this->request->data['deviceType']))
				$deviceType         = $this->request->data['deviceType'];
			else
				$deviceType = '';
		
			if(isset($this->request->data['user_id']))
			{
				if(!empty($this->request->data['user_id']))
					$user_id = $this->request->data['user_id'];
			}
			else
				$user_id = '';


			$id = $this->request->data['store_id'];

			//echo json_encode($user_id); exit;
			$user_lat = $this->request->data['user_lat'];
			$user_lng = $this->request->data['user_lng'];//type=bookmark,like
			$unit = 'km';

			$result = $res = array();
			$result2 = $res2 = array();


			$this->loadModel('Category');
			$this->loadModel('Filerec');
			$this->loadModel('Outlet');
			$this->loadModel('Like');
			$this->loadModel('Deal');
			$this->loadModel('Review');
			$this->loadModel('User');


			if($this->request->data['deviceType']){
			$data['Analytic']['device_type'] = $this->request->data['deviceType'];
			}
		
			$this->loadModel('Analytic');        
			$data['Analytic']['type']      = 'views';
			$data['Analytic']['ref_id']    = $id;
			$data['Analytic']['item_type'] = 'outlet';
			$this->Analytic->save($data);
			
			if(isset($this->request->data['user_id']))
			{
				if(!empty($this->request->data['user_id']))
				{	
					$user_like = $this->Like->find('first',array('fields'=>array('like_unlike_status','rating'),'conditions'=>array('user_id'=>$user_id,'type_id'=>$id,'type'=>'store')));
				}	
			}
			

			$rating = $this->Like->find('all',array('fields'=>array('AVG(Like.rating) as Average'),'conditions'=>array('type_id'=>$id,'type'=>'store')));

			
			$this->Outlet->updateAll(array('viewed' => 'viewed+1'),array('id' => $id));
			$subcat = $this->Outlet->find('all', array('fields' => array('review_count','like_count','follow_count','phone_no','id','title','category','address','city','state','country','lat','lng','timings','banner','status'), 'order' => 'Outlet.title asc','conditions' => array('status' => 1, 'id'=>$id)));
			$i = 0;
			foreach($subcat as $cat){
				$res[$i]['id'] = $cat['Outlet']['id'];
				$res[$i]['name'] = $cat['Outlet']['title'];
				$res[$i]['address'] = $cat['Outlet']['address'];
				$res[$i]['city'] = $cat['Outlet']['city'];
				$res[$i]['state'] = $cat['Outlet']['state'];
				$res[$i]['country'] = $cat['Outlet']['country'];
				$res[$i]['lat'] = $cat['Outlet']['lat'];
				$res[$i]['lng'] = $cat['Outlet']['lng'];

				if($rating=='Null')
					$res[$i]['avg_rating'] = $rating;
				else
					$res[$i]['avg_rating'] = 0;

				$theta = $res[$i]['lng'] - $user_lng;
				$dist = sin(deg2rad($res[$i]['lat'])) * sin(deg2rad($user_lat)) +  cos(deg2rad($res[$i]['lat'])) * cos(deg2rad($user_lat)) * cos(deg2rad($theta));
				$dist = acos($dist);
				$dist = rad2deg($dist);
				$distance = round($dist * 60 * 1.1515*1.609344,2).' KM';
				 	  	  	    
 	  	  	    $res[$i]['distance'] = $distance;
				$res[$i]['timings'] = $cat['Outlet']['timings'];
				$res[$i]['like_count'] = $cat['Outlet']['like_count'];
				
				if(isset($this->request->data['user_id']))
				{
					if(!empty($this->request->data['user_id']))
					{
						if($user_like)
						{
							$res[$i]['user_like_status'] = $user_like['Like']['like_unlike_status'];
							$res[$i]['user_rating'] = $user_like['Like']['rating'];		
						}
						else
						{	
							$res[$i]['user_like_status'] = 0;
							$res[$i]['user_rating'] = 0;
						}
						
					}
				}

				$res[$i]['follow_count'] = $cat['Outlet']['follow_count'];
				$res[$i]['review_count'] = $cat['Outlet']['review_count'];
						
				$res[$i]['phone_no'] = $cat['Outlet']['phone_no'];

				$res[$i]['cat_id'] = $cat['Outlet']['category'];

				$status = $this->Category->find('all', array('fields'=>array('id','title'), 'conditions'=>array('id'=>$res[$i]['cat_id'])));
					foreach ($status as $row) {
						$res[$i]['category'] = $row['Category']['title'];
					}
				
				$res[$i]['banner_img'] = DISPLAY_OUTLET_DIR.$cat['Outlet']['banner'];

				$gallery = $this->Filerec->find('all',array('fields'=>array('id','ref_id','ref_type','file_name'), 'conditions'=>array('ref_id'=>$id, 'ref_type'=>1)));
				
				$arr= array();
				$k=0;	
				foreach($gallery as $gal)
				{
					$arr[$k]['img']=DISPLAY_OUTLET_DIR.$gal['Filerec']['file_name'];
					$k++;
				}

				$res[$i]['gallery_img'] = $arr;//DISPLAY_OUTLET_DIR.$cat['Outlet']['banner'];
				
				$deal_arr = array();
				$deal = $this->Deal->find('all',array('fields'=>array('id','deal_name','deal_price'),'conditions'=>array('Deal.status'=>1,'Deal.outlet'=>$id)));
				$l=0;
				foreach($deal as $d)
				{
					$deal_arr[$l]['deal_id'] = $d['Deal']['id'];
					$deal_arr[$l]['deal_name'] = $d['Deal']['deal_name'];
					$deal_arr[$l]['deal_price'] = $d['Deal']['deal_price'];
					$l++;					
				}
				$res[$i]['deals'] = $deal_arr;


				$review_arr = array();
				$review_details = $this->Review->find('all',array('fields'=>array('id','user_id','review','modified'),'conditions'=>array('Review.status'=>1,'Review.ref_id'=>$id,'Review.type'=>'store')));
				$l=0;
				foreach($review_details as $r)
				{
					$review_arr[$l]['review_id'] = $r['Review']['id'];
					$review_arr[$l]['review_content'] = $r['Review']['review'];
					$review_arr[$l]['modified_time'] = $r['Review']['modified'];

					$review_arr[$l]['user_id'] = $r['Review']['user_id'];
					$user_details = $this->User->find('first',array('fields'=>array('first_name','last_name','profile_img'), 'conditions'=>array('User.id'=>$review_arr[$l]['user_id'])));
					$review_arr[$l]['user_name'] = $user_details['User']['first_name'].' '.$user_details['User']['last_name'];
					$review_arr[$l]['user_pic'] = DISPLAY_USERS_DIR.$user_details['User']['profile_img'];

					$l++;					
				}
				$res[$i]['reviews'] = $review_arr;

				$i++;
			}
			$result['store'] = $res;
			$result['status'] = 1;			

		$a = json_encode($result);
		echo preg_replace('/[\x00-\x1F\x80-\xFF]/', '', $a);
		exit;
	}


	function storedetail3()
	{

			$result1 = $res = array(); //for store
								
			$this->loadModel('Category');
			$this->loadModel('Like');
			$this->loadModel('Outlet');
			

			$user_lat = $this->request->data['user_lat'];
			$user_lng = $this->request->data['user_lng'];


			$subcat = $this->Outlet->find('all', array('fields' => array('id','title','category','address','city','state','country','lat','lng','timings','banner','status'), 'order' => 'Outlet.title asc','conditions' => array('status' => 1)));
			$i = 0;
			foreach($subcat as $cat){
				$res[$i]['id'] = $cat['Outlet']['id'];
				$res[$i]['name'] = $cat['Outlet']['title'];
				$res[$i]['lat'] = $cat['Outlet']['lat'];
				$res[$i]['lng'] = $cat['Outlet']['lng'];
				$res[$i]['timings'] = $cat['Outlet']['timings']; 
				$res[$i]['state'] = $cat['Outlet']['state']; 
				$res[$i]['country'] = $cat['Outlet']['country']; 
				
				$theta = $res[$i]['lng'] - $user_lng;
				$dist = sin(deg2rad($res[$i]['lat'])) * sin(deg2rad($user_lat)) +  cos(deg2rad($res[$i]['lat'])) * cos(deg2rad($user_lat)) * cos(deg2rad($theta));
				$dist = acos($dist);
				$dist = rad2deg($dist);
				$distance = round($dist * 60 * 1.1515*1.609344,2);

				$res[$i]['distance'] = $distance.' KM';

				$res[$i]['img'] = DISPLAY_OUTLET_DIR.$cat['Outlet']['banner'];
				$i++;
			}

			//asort($res);

			$result['store'] = $res;
			$result['status'] = 1;
							
		function mysort($a,$b){
			if ($a['distance'] < $b['distance']) {
        			return -1;
    			} else if ($a['distance'] > $b['distance']) {
        			return 1;
    			} else {
  			      return 0;
    			}
    	}

		$a = json_encode($result);
		$b = preg_replace('/[\x00-\x1F\x80-\xFF]/', '', $a);

		$d = json_decode($b,true);
		$info = $d['store'];
		usort($info,'mysort');

		$test['store'] = $info;
		$test['status'] = 1;
		
		echo json_encode($test);
		exit;
	}


	/*Deals API section*/
	function dealdetail()
	{
		if(isset($this->request->data['deviceType']))
			$deviceType = $this->request->data['deviceType'];
		else
			$deviceType = '';
		
		if(isset($this->request->data['user_id']))
		{
			if(!empty($this->request->data['user_id']))
				$user_id = $this->request->data['user_id'];
			else
				$user_id = '';
		}
		else
		$user_id = '';

		$id = $this->request->data['deal_id'];

		$result = $res = array();					
		$this->loadModel('Category');
		$this->loadModel('Filerec');
		$this->loadModel('Outlet');
		$this->loadModel('OutletName');
		$this->loadModel('Like');
		$this->loadModel('Deal');
		$this->loadModel('Review');
		$this->loadModel('User');

		if(isset($this->request->data['deviceType'])){
			$data['Analytic']['device_type'] = $this->request->data['deviceType'];
		}
		
		$this->loadModel('Analytic');        
		$data['Analytic']['type']      = 'views';
		$data['Analytic']['ref_id']    = $id;
		$data['Analytic']['item_type'] = 'deal';
		$this->Analytic->save($data);
			
		if(isset($this->request->data['user_id']))
		{
			if(!empty($this->request->data['user_id']))
			{	
				$user_like = $this->Like->find('first',array('fields'=>array('like_unlike_status'),'conditions'=>array('user_id'=>$user_id,'type_id'=>$id,'type'=>'deal')));
			}	
		}
			

		$this->Deal->updateAll(array('Deal.viewed' =>'Deal.viewed + 1'), array('Deal.id' => $id));
	
		$deal = $this->Deal->find('all', array('fields' => array('id','user_id','outlet','deal_name','deal_price','discounted_price','description','logo','start_time','end_time','like_count','review_count','viewed','view_count','status'), 'conditions' => array('Deal.status' => 1, 'Deal.id'=>$id)));
		
		//$deal_list = $this->Deal->find('first',array('fields'=>array('deal_name'), 'conditions'=>array('Deal.id'=>$id)));
		if($deal)
		{
		$i = 0;
		foreach($deal as $d){
			$res[$i]['id'] = $d['Deal']['id'];
			$res[$i]['user_id'] = $d['Deal']['user_id'];
			$res[$i]['store_id'] = $d['Deal']['outlet'];

			$store = $this->Outlet->find('first', array('fields' => array('id','title','address','city','state','country'), 'conditions' => array('Outlet.status' => 1, 'Outlet.id'=>$d['Deal']['outlet'])));		
			if($store)
			{
				$res[$i]['store_name'] = $store['Outlet']['title'];
				$res[$i]['store_address'] = $store['Outlet']['address'];
				$res[$i]['store_city'] = $store['Outlet']['city'];
				$res[$i]['store_state'] = $store['Outlet']['state'];
				$res[$i]['store_country'] = $store['Outlet']['country'];
			}
			else
			{
				$res[$i]['store_status'] = 'Store Not Active';
			}

			$res[$i]['deal_name'] = $d['Deal']['deal_name'];
			$res[$i]['deal_price'] = $d['Deal']['deal_price'];
			$res[$i]['discounted_price'] = $d['Deal']['discounted_price'];
			
			$res[$i]['description'] = htmlspecialchars($d['Deal']['description']);
			
			$res[$i]['start_time'] = $d['Deal']['start_time'];
			$res[$i]['end_time'] = $d['Deal']['end_time'];
			$res[$i]['like_count'] = $d['Deal']['like_count'];
			//$res[$i]['view_count'] = $d['Deal']['view_count'];
			$res[$i]['review_count'] = $d['Deal']['review_count'];
			$res[$i]['viewed'] = $d['Deal']['viewed'];
			$res[$i]['logo'] = DISPLAY_DEAL_DIR.$d['Deal']['logo'];

				
			if(isset($this->request->data['user_id']))
			{
				if(!empty($this->request->data['user_id']))
				{
					if($user_like)
					{
						$res[$i]['user_like_status'] = $user_like['Like']['like_unlike_status'];
					}
					else
					{	
						$res[$i]['user_like_status'] = 0;
					}
				}
			}

			$gallery = $this->Filerec->find('all',array('fields'=>array('id','ref_id','ref_type','file_name'), 'conditions'=>array('ref_id'=>$id, 'ref_type'=>2)));
			$arr= array();
			$k=0;	
			foreach($gallery as $gal)
			{
				$arr[$k]['img']=DISPLAY_DEAL_DIR.$gal['Filerec']['file_name'];
				$k++;
			}
			$res[$i]['gallery_img'] = $arr;//DISPLAY_OUTLET_DIR.$cat['Outlet']['banner'];
			
			$deal_reviews = $this->Review->find('all',array('field'=>array('Review.id','user_id','review','modified'),'conditions'=>array('ref_id'=>$id)));
			$review_arr = array();
			$l=0;
			foreach($deal_reviews as $rev){
				$review_arr[$l]['rev_id'] = $rev['Review']['id'];
				$review_arr[$l]['rev'] = $rev['Review']['review'];
				$review_arr[$l]['user_id'] = $rev['Review']['user_id'];
				$review_arr[$l]['modified'] = $rev['Review']['modified'];

				$user_details = $this->User->find('first',array('fields'=>array('first_name','last_name','profile_img'), 'conditions'=>array('User.id'=>$review_arr[$l]['user_id'])));
				$review_arr[$l]['user_name'] = $user_details['User']['first_name'].' '.$user_details['User']['last_name'];
				$review_arr[$l]['user_pic'] = DISPLAY_USERS_DIR.$user_details['User']['profile_img'];	
				$l++;
			}
			$res[$i]['review_list'] = $review_arr;

			$i++;
		}
		$result['deal'] = $res;
		$result['status'] = 1;
		}
		else
		{
			$result['msg'] = 'Deal Not Active';
			$result['status']=0;
		}
					

		$a = json_encode($result);
		echo preg_replace('/[\x00-\x1F\x80-\xFF]/', '', $a);
		exit;
	}



	function user_profile(){
		if(isset($this->request->data['user_id'])){
			$user_id = $this->request->data['user_id'];

			$result = $res = array();
			$this->loadModel('Like');

			//$deal_count = $this->Like->find('all', array('fields'=>'count(id)'), 'conditions'=>array('user_id'=>$user_id,'type'=>'deal'));
			$deal_count = $this->Like->find('count',array('field'=>array('count(id)'),'conditions'=>array('user_id'=>$user_id,'type'=>'deal','like_unlike_status'=>1)));
			$res['deal_count'] = $deal_count;

			$category_count = $this->Like->find('count',array('field'=>array('count(id)'),'conditions'=>array('user_id'=>$user_id,'type'=>'category','like_unlike_status'=>1)));
			$res['category_count'] = $category_count;

			$store_count = $this->Like->find('count',array('field'=>array('count(id)'),'conditions'=>array('user_id'=>$user_id,'type'=>'store','like_unlike_status'=>1)));
			$res['store_count'] = $store_count;

			$this->loadModel('Review');
			$review_count = $this->Review->find('count',array('field'=>array('count(id)'),'conditions'=>array('user_id'=>$user_id)));
			$res['review_count'] = $review_count;	

			$result['user_profile'] = $res;
			$result['status'] =1;
		}
		else
		{
			$result['msg'] = 'Deal Not Active';
			$result['status']=0;
		}
		$a = json_encode($result);
		echo preg_replace('/[\x00-\x1F\x80-\xFF]/', '', $a);
		exit;
	}












    function getOutletBookmark()
	{
		$type 	   = $this->request->data['type'];//type=bookmark,like
		$ref_type  = $this->request->data['ref_type'];	//ref_type=(1=outlet,2=review) 	
		$id        = $this->request->data['user_id'];
		$address = $this->request->data['location']	;
		$reqData = $this->request->data;
		$geo = file_get_contents('http://maps.googleapis.com/maps/api/geocode/json?address='.urlencode($address).'&sensor=false');
		$geo = json_decode($geo, true);	
		$latitude = $longitude = '';
		if ($geo['status'] = 'OK') {			
			$latitude = $geo['results'][0]['geometry']['location']['lat'];
			$longitude = $geo['results'][0]['geometry']['location']['lng'];	
		}		
		$result['success'] = 0;					
		$this->loadModel('Outlet');
		$cond_arr = array('Outlet.status' => 1);
		$add_feat_cond = '';
		$ord_by = 'Outlet.id desc';
		$group_by = 'Outlet.id';
		$add_fields = array();
		$add_feat_cond .= ' and OutletFeatured.category_parent_id is null';
		
		$joins = array(
			array(
				'table' => 'cities',
				'alias' => 'City',
				'type' => 'left',
				'conditions' => array('City.id = Outlet.city')
			),
			array(
				'table' => 'outlet_names', 
				'alias' => 'OutletName',
				'type' => 'left',
				'conditions' => array('OutletName.id = Outlet.outlet_name_id')
			),
			array(
				'table' => 'filerecs',
				'alias' => 'Filerec',
				'type' => 'left',
				'conditions' => array('Outlet.id = Filerec.ref_id and Filerec.ref_type=1')
				),					
			array(
						'table' => 'parcategory', 
						'alias' => 'OutletType',
						'type' => 'left',
						'conditions' => array('OutletType.id = Outlet.category_parent_id')
			)
			);
			
			if(!empty($this->request->data['user_id']))
			{
				$joins[] = array(
						'table' => 'likes',
						'alias' => 'Bookmark',
						'type' => 'inner',
						'conditions' => array('Bookmark.ref_id = Outlet.id', 'Bookmark.user_id' => $this->request->data['user_id'], 'Bookmark.ref_type' => '1', 'Bookmark.type' => 'bookmark')
					);						
				$add_fields = array('Bookmark.id');
			}
			$offset = 0;
			if(!empty($this->request->data['page']))
			{
				$offset = ($this->request->data['page'] <= 0 ? 0 : $this->request->data['page'] - 1);
			}
			
			$this->paginate = array(
					'fields' => array_merge(array('Outlet.id','banner','lat','lng','OutletType.name','Outlet.mem_type','Outlet.type', 'Outlet.title', 'Outlet.address', 'Outlet.phone_no2', 'Outlet.personal_mob_no', 'Outlet.phone_no', 'OutletName.title', 'OutletName.logo', 'City.title', 'Filerec.file_name', '(select avg(Review.rating) from reviews as `Review` where `Review`.ref_id = Outlet.id and `Review`.type = "outlet" and `Review`.status = 1) as avg_rating'), $add_fields),
					'joins' => $joins, 
					'conditions' => $cond_arr, 
					'group' => $group_by, 
					'order' => $ord_by, 
					'limit' => 20,
					'offset' => $offset
				);

			$result_out = $this->paginate('Outlet');				
			if(	count($result_out) > 0){
				 $arr = $featured_arry = array();
				 $i = 0;
				foreach($result_out as $k){
					
					$lat1 = ($reqData['user_lat'] != 0 ? $reqData['user_lat'] : $latitude);
					$lon1 = ($reqData['user_long'] != 0 ? $reqData['user_long'] : $longitude);
					$lat2 = $k['Outlet']['lat'];
					$lon2 = $k['Outlet']['lng'];						
					$img_name 				= $k['Filerec']['file_name'];
					$dotpos 				= strrpos($img_name, '.');
					$firstpart 			    = substr($img_name, 0, $dotpos);
					$ext 					= substr($img_name, ($dotpos+1));
					$arr[$i]['id'] 			= $k['Outlet']['id'];
					$arr[$i]['name'] 		= $k['Outlet']['title'];
					$arr[$i]['market_type'] = ($k['OutletType']['name'] == null ? '' : $k['OutletType']['name']);
					$arr[$i]['bookmark']    = (isset($k['Bookmark']['id']) ? ($k['Bookmark']['id'] != '' ? 'yes' : 'no') : 'no') ;
					$arr[$i]['rating']		= number_format((float)$k['0']['avg_rating'], 2, '.', '');
					$arr[$i]['phone_no']	= ($k['Outlet']['phone_no'] != '' ? $k['Outlet']['phone_no'] : '').($k['Outlet']['phone_no2'] != '' ? ' ,'.$k['Outlet']['phone_no2'] : '').($k['Outlet']['personal_mob_no'] != '' ? ' ,'.$k['Outlet']['personal_mob_no'] : '');
					$arr[$i]['location']	= ($k['City']['title'] != '' ? $k['City']['title'] : '');
					$arr[$i]['distance']    = number_format((float)$this->distance($lat1, $lon1, $lat2, $lon2, 'K'), 2, '.','');
					$arr[$i]['user_lat']    =  $lat1;
					$arr[$i]['lat']         =  $lat2;
					$arr[$i]['long']        =  $lon2;
					$arr[$i]['user_long']   =  $lon1;			
					$arr[$i]['image']		= ($k['Outlet']['banner'] != '' ? SITE_URL.'uploads/outlet/'.$k['Outlet']['banner'] : '');
					$image_ipad = $img_name = '';
					if($k['Outlet']['banner'] != '' )
					{
						$img_name = DISPLAY_OUTLET_DIR.'129x117_'.$k['Outlet']['banner'];
						$image_ipad = DISPLAY_OUTLET_DIR.'156x131_'.$k['Outlet']['banner'];
						if(!file_exists(UPLOAD_OUTLET_DIR.'156x131_'.$k['Outlet']['banner'])){				
							$this->Image->resize_crop_image(156,131, UPLOAD_OUTLET_DIR.$k['Outlet']['banner'], UPLOAD_OUTLET_DIR.'156x131_'.$k['Outlet']['banner']);
						}
						if(!file_exists(UPLOAD_OUTLET_DIR.'129x117_'.$k['Outlet']['banner'])){				
							$this->Image->resize_crop_image(129,117, UPLOAD_OUTLET_DIR.$k['Outlet']['banner'], UPLOAD_OUTLET_DIR.'129x117_'.$k['Outlet']['banner']);
						}
					}
					$arr[$i]['image'] 	  = $img_name;
					$arr[$i]['image_ipad'] = $image_ipad;
					$i++;
				}
				$result['success'] = 1;
				$result['result'] = $arr;				
			}
			else
			{
			 $result['msg'] = 'No record found';
			}				
				
		
		echo json_encode($result);
		exit;		
	}
	
	function bookmarklike($cat_id, $user_id, $type)
	{
		$res_arr = $result = array();
		if(!empty($this->request->data))
		{
			$this->loadModel('Like');
			$user = $this->request->data;
            //user_id=19&ref_id=216&type=bookmark,like&ref_type=1 			
			if(isset($user['deviceType'])){
				$user['device_type'] = $user['deviceType'];
			}
			$check = $this->Like->find('first', array('conditions' => array('ref_id' => $user['ref_id'],'ref_type' => $user['ref_type'],'type' => $user['type'],'user_id' => $user['user_id'])));
			if(!empty($check))
			{	
				//delete  code here
				$id= $check['Like']['id'];
				$this->Like->delete($id);
				$res_arr['msg'] = 'UnBookmark';	
			}
			else
			{
                $this->Like->save($user);
				$res_arr['msg'] = 'Bookmark successfully';
			}
            $likescount = $this->Like->find('count', array('conditions' => array('ref_type' =>$user['ref_type'],'ref_id' => $user['ref_id'],'type' => $user['type'])));         
			$res_arr['status'] = 1;
			$res_arr['likecount'] = $likescount;
		}		
		else
		{
			$res_arr['msg'] =  'Invalid post request';
			$res_arr['status'] = 0;
		}
		echo json_encode($res_arr);
		exit;		
	}


	//Category Like/Unlike Webservice
	function all_like_unlike()
	{
		if(isset($this->request->data['deviceType']))
			$deviceType         = $this->request->data['deviceType'];
		else
			$deviceType = '';

		$type_id            = $this->request->data['id'];//type=bookmark,like
		$like_unlike_status = $this->request->data['status'];//ref_type=(1=outlet,2=review) 	
		$type         		= $this->request->data['type'];
		$user_id 			= $this->request->data['user_id'];

		$res_arr = $result = array();
		
		if(!empty($this->request->data))
		{
			$this->loadModel('Like');
			if($type=='category')
			{
				$count = $this->Like->find('count', array('conditions' => array('user_id' =>$user_id,'type_id' => $type_id,'type'=>$type)));	
				if($count==0)
				{
					$this->Like->create();				
					$this->Like->save(array('user_id'=>$user_id, 'like_unlike_status'=>$like_unlike_status, 'type'=>$type, 'type_id'=>$type_id, 'device_type'=>$deviceType));
				}
				else
					$this->Like->updateAll(array('like_unlike_status'=>$like_unlike_status),array('user_id'=>$user_id,'type'=>$type,'type_id'=>$type_id));

				$res_arr['msg'] =  'Successful';
				$res_arr['status'] = 1;
			}
			elseif($type=='store')
			{
				$this->loadModel('Outlet');
				$count = $this->Like->find('count', array('conditions' => array('user_id' =>$user_id,'type_id' => $type_id,'type'=>$type)));	
				
				if($count==0)
				{
					$this->Like->create();				
					$this->Like->save(array('user_id'=>$user_id, 'like_unlike_status'=>$like_unlike_status, 'type'=>$type, 'type_id'=>$type_id, 'device_type'=>$deviceType));
					$this->Outlet->updateAll(array('like_count'=>'like_count+1'),array('id'=>$type_id));
				}
				else
				{
					//$st = $count['Like']['']
					$this->Like->updateAll(array('like_unlike_status'=>$like_unlike_status),array('user_id'=>$user_id,'type'=>$type,'type_id'=>$type_id));
					if($like_unlike_status==0)
						$this->Outlet->updateAll(array('like_count'=>'like_count-1'),array('id'=>$type_id));
					if($like_unlike_status==1)
					{
						$this->Outlet->updateAll(array('like_count'=>'like_count+1'),array('id'=>$type_id));
						//$res_arr['test'] = 'hello';
					}
					
				}

				$res_arr['msg'] =  'Successful';
				$res_arr['status'] = 1;
			}
			elseif($type=='deal')
			{
				$this->loadModel('Deal');
				$count = $this->Like->find('count', array('conditions' => array('Like.user_id' =>$user_id,'Like.type_id' => $type_id,'Like.type'=>'deal')));
					
				if($count==0)
				{
					$this->Like->create();				
					$this->Like->save(array('user_id'=>$user_id, 'like_unlike_status'=>$like_unlike_status, 'type'=>'deal', 'type_id'=>$type_id, 'device_type'=>$deviceType));
					$this->Deal->updateAll(array('like_count'=>'like_count+1'),array('id'=>$type_id));
				}
				else
				{
					//$st = $count['Like']['']
					$this->Like->updateAll(array('like_unlike_status'=>$like_unlike_status),array('user_id'=>$user_id,'type'=>'deal','type_id'=>$type_id));
					if($like_unlike_status==0)
						$this->Deal->updateAll(array('like_count'=>'like_count-1'),array('Deal.id'=>$type_id));
					if($like_unlike_status==1)
					{
						$this->Deal->updateAll(array('like_count'=>'like_count+1'),array('Deal.id'=>$type_id));
						//$res_arr['test'] = 'hello';
					}
					
				}
				$res_arr['msg'] =  'Successful';
				$res_arr['status'] = 1;
			}
		}		
		else
		{
			$res_arr['msg'] =  'Invalid post request';
			$res_arr['status'] = 0;
		}
		
		echo json_encode($res_arr);
		exit;		
	}


	/*All Rating API Function*/
	function all_rating_review()
	{
		if(isset($this->request->data['deviceType']))
			$deviceType = $this->request->data['deviceType'];
		else
			$deviceType = '';


		if(isset($this->request->data['rate']))
			$rate = $this->request->data['rate'];
		
		$type_id  = $this->request->data['id'];//type=bookmark,like9*
		$type   	= $this->request->data['type'];
		$user_id	= $this->request->data['user_id'];

		if(isset($this->request->data['ref_type']))
			$ref_type = $this->request->data['ref_type'];

		$res_arr = $result = array();
		
		if(!empty($this->request->data))
		{
			$this->loadModel('Like');
			$this->loadModel('Review');
			$this->loadModel('Outlet');

			if($type=='store')
			{
				if($ref_type=='rate')
				{
					$count = $this->Like->find('count', array('conditions' => array('user_id' =>$user_id,'type_id' => $type_id,'type'=>$type)));	
					if($count==0)
					{
						$this->Like->create();				
						$this->Like->save(array('user_id'=>$user_id, 'rating'=>$rate, 'type'=>'store', 'type_id'=>$type_id, 'device_type'=>$deviceType));
					}
					else
					{
						$this->Like->updateAll(array('rating'=>$rate),array('user_id'=>$user_id,'type'=>$type,'type_id'=>$type_id));
					}

					$res_arr['msg'] =  'Successful';
					$res_arr['status'] = 1;
				}
				elseif($ref_type=='review')
				{
					$review_content = $this->request->data['review_content'];
					$this->Review->save(array('user_id'=>$user_id, 'ref_id'=>$type_id, 'rating'=>$rate, 'review'=>$review_content, 'type'=>$type, 'device_type'=>$deviceType, 'status'=>1));

					$count = $this->Like->find('count', array('conditions' => array('user_id' =>$user_id,'type_id' => $type_id,'type'=>$type)));	
					if($count==0)
					{
						$this->Like->create();				
						$this->Like->save(array('user_id'=>$user_id, 'rating'=>$rate, 'type'=>'store', 'type_id'=>$type_id, 'device_type'=>$deviceType));
					}
					else
					{
						$this->Like->updateAll(array('rating'=>$rate),array('user_id'=>$user_id,'type'=>$type,'type_id'=>$type_id));
					}						
					

					$res_arr['review_content'] =  $review_content;
					$res_arr['msg'] =  'Successful';
					$res_arr['status'] = 1;
				}
			}

			elseif($type=='deal')
			{
				if($ref_type=='rate')
				{
					$count = $this->Like->find('count', array('conditions' => array('user_id' =>$user_id,'type_id' => $type_id,'type'=>$type)));	
					if($count==0)
					{
						$this->Like->create();				
						$this->Like->save(array('user_id'=>$user_id, 'rating'=>$rate, 'type'=>'deal', 'type_id'=>$type_id, 'device_type'=>$deviceType));
					}
					else
					{
						$this->Like->updateAll(array('rating'=>$rate),array('user_id'=>$user_id,'type'=>$type,'type_id'=>$type_id));
					}

					$res_arr['msg'] =  'Successful';
					$res_arr['status'] = 1;
				}
				elseif($ref_type=='review')
				{
					$review_content = $this->request->data['review_content'];
					$this->Review->save(array('user_id'=>$user_id, 'ref_id'=>$type_id, 'rating'=>$rate, 'review'=>$review_content, 'type'=>$type, 'device_type'=>$deviceType, 'status'=>1));

					$count = $this->Like->find('count', array('conditions' => array('user_id' =>$user_id,'type_id' => $type_id,'type'=>$type)));	
					if($count==0)
					{
						$this->Like->create();				
						$this->Like->save(array('user_id'=>$user_id, 'rating'=>$rate, 'type'=>'deal', 'type_id'=>$type_id, 'device_type'=>$deviceType));
					}
					else
					{
						$this->Like->updateAll(array('rating'=>$rate),array('user_id'=>$user_id,'type'=>$type,'type_id'=>$type_id));
					}			

					$res_arr['review_content'] =  $review_content;
					$res_arr['msg'] =  'Successful';
					$res_arr['status'] = 1;
				}
			}
		}		
		else
		{
			$res_arr['msg'] =  'Invalid post request';
			$res_arr['status'] = 0;
		}
		
		echo json_encode($res_arr);
		exit;		
	}
	
	


    function getReviewOutlet()
	{		
		$result['success'] = 0;					
		$this->loadModel('Outlet');
		$cond_arr = array('Outlet.status' => 1,'Reviews.review !=' => '');
		$add_feat_cond = '';
		$ord_by = 'Reviews.created desc';
		$group_by = 'Outlet.id';
		$add_fields = array();		
		$user_id = $this->request->data['user_id'];
		
		$joins = array(
			array(
				'table' => 'cities',
				'alias' => 'City',
				'type' => 'left',
				'conditions' => array('City.id = Outlet.city')
			),
			array(
				'table' => 'outlet_names', 
				'alias' => 'OutletName',
				'type' => 'left',
				'conditions' => array('OutletName.id = Outlet.outlet_name_id')
			),
			array(
				'table' => 'reviews', 
				'alias' => 'Reviews',
				'type' => 'inner',
				'conditions' => array('Reviews.ref_id = Outlet.id and Reviews.user_id="'.$user_id.'"')
			),
			array(
				'table' => 'filerecs',
				'alias' => 'Filerec',
				'type' => 'left',
				'conditions' => array('Outlet.id = Filerec.ref_id and Filerec.ref_type=1')
				),					
			array(
				'table' => 'outlet_types', 
				'alias' => 'OutletType',
				'type' => 'left',
				'conditions' => array('OutletType.id = Outlet.type')
			),
			array(
					'table' => 'likes',
					'alias' => 'Like',
					'type' => 'left',
					'conditions' => array('Like.ref_id = Outlet.id', 'Like.user_id' => $this->request->data['user_id'], 'Like.ref_type' => '1', 'Like.type' => 'like')
				)	
			);
						
			$add_fields = array('Like.id');
			
			$offset = 0;
			if(!empty($this->request->data['page']))
			{
				$offset = ($this->request->data['page'] <= 0 ? 0 : $this->request->data['page'] - 1);
			}
			
			$this->paginate = array(
					'fields' => array_merge(array('Reviews.*,Outlet.id','lat','lng','OutletType.title','Outlet.mem_type','Outlet.type', 'Outlet.title', 'Outlet.address', 'Outlet.phone_no', 'OutletName.title', 'OutletName.logo', 'City.title', 'Filerec.file_name', '(select avg(Review.rating) from reviews as `Review` where `Review`.ref_id = Outlet.id and `Review`.type = "outlet" and `Review`.status = 1) as avg_rating'), $add_fields),
					'joins' => $joins, 
					'conditions' => $cond_arr, 
					'group' => $group_by, 
					'order' => $ord_by, 
					'limit' => 20,
					'offset' => $offset
				);
			
			$result_out = $this->paginate('Outlet');				
			if(	count($result_out) > 0){
				 $arr = array();
				 $i = 0;
				 $this->loadModel('Like');
				foreach($result_out as $k){					
								
					$img_name 				= $k['Filerec']['file_name'];
					$dotpos 				= strrpos($img_name, '.');
					$firstpart 			    = substr($img_name, 0, $dotpos);
					$ext 					= substr($img_name, ($dotpos+1));
					$arr[$i]['review_id'] 	= $k['Reviews']['id'];
					$arr[$i]['name'] 		= $k['Outlet']['title'];
					$arr[$i]['market_type'] = ($k['OutletType']['title'] == null ? '' : $k['OutletType']['title']);					
					$arr[$i]['rating']		= ($k['Reviews']['rating'] != '' ? $k['Reviews']['rating'] : '');
					$arr[$i]['review']		= ($k['Reviews']['review'] != '' ? $k['Reviews']['review'] : '');
					$arr[$i]['review_created']= $k['Reviews']['created'] ;
					$arr[$i]['current_date']  = date('Y-m-d H:i:s');
					$arr[$i]['ago'] 		  = formatDateTimeAgoStruct($k['Reviews']['created']);	
					$arr[$i]['phone_no']	= ($k['Outlet']['phone_no'] != '' ? $k['Outlet']['phone_no'] : '');
					$arr[$i]['location']	= ($k['City']['title'] != '' ? $k['City']['title'] : '');
					$arr[$i]['like']		= ($k['Like']['id'] != '' ? 'yes' : 'no');
					$arr[$i]['status']		= ($k['Reviews']['status'] == 1 ? 'approved' : ($k['Reviews']['status'] == 2 ? 'pending' : 'rejected'));
					$arr[$i]['likecount']   = $this->Like->find('count', array('conditions' => array('Like.ref_type' => 1,'Like.ref_id' => $k['Outlet']['id'],'Like.type' => 'like')));  
					$arr[$i]['image']		= ($img_name != '' ? SITE_URL.'uploads/outlet/'.$firstpart.'_353x226.'.$ext : '');
					$i++;
				}
				$result['success'] = 1;
				$result['result'] = $arr;				
			}
			else
			{
			 $result['msg'] = 'No record found';
			}
		echo json_encode($result);
		exit;
	}
	
	
	function reviewList()
	{		
		$outlet_id = $this->request->data['outlet_id'];		
		$this->loadModel('Review');
		$this->Review->bindModel(array(
									'belongsTo'  => array(
											'User' => array(
													'fields' => array('User.id,User.address,User.display_name,profile_img'),
													'conditions' => array('Review.user_id=User.id')
												)
											)
										)
									);
	    $offset = 0;
		if(!empty($this->request->data['page']))
		{
			$offset = ($this->request->data['page'] <= 0 ? 0 : $this->request->data['page'] - 1);
		}							
		$reviews = $this->Review->find('all', array('offset' => $offset, 'limit' => 20,'order' => array('Review.id desc'), 'conditions' => array('Review.status' => 1,'Review.review !=' => '','Review.ref_id' => $outlet_id,'Review.type' => 'outlet')));
		$arr = array();
		if(count($reviews) > 0)
		{
			$i =0;
			foreach($reviews as $review)
			{
				$arr[$i]['review'] 	     = $review['Review']['review'];
				$arr[$i]['rating'] 	     = $review['Review']['rating'];
				$arr[$i]['created_date'] = $review['Review']['created'];
				$arr[$i]['current_date'] = date('Y-m-d H:i:s');
				$arr[$i]['ago'] 		 = formatDateTimeAgoStruct($review['Review']['created']);
				$arr[$i]['username']     = $review['User']['display_name'];
				$arr[$i]['address']      = $review['User']['address'];
				$arr[$i]['profile_img']  = (!empty($review['User']['profile_img']))? SITE_URL.UPLOAD_USERS_DIR.$review['User']['profile_img'] : 1;
				$i++;
		   }
		   $result['status'] = 1;
		   $result['result'] = $arr;	
		}
		else 
		{
		   $result['status'] = 0;
		  $result['msg'] = 'No record found';
		}
		echo json_encode($result);
		exit;			
	}
	


	function statesRating()
	{	
		$this->LoadModel('Review');
		$this->loadModel('Setting');
		$this->LoadModel('Like');
		$res_arr = $result = array();
		if(!empty($this->request->data))
		{
			 $user_id = $this->request->data['user_id'];
			 $num_reviews = $this->Review->find('count', array('conditions' => array('Review.status' => 1,'Review.review !=' => '','Review.user_id' => $user_id, 'Review.type' => 'outlet')));
			 $num_bookmarks = $this->Like->find('count', array('conditions' => array('Like.user_id' => $user_id, 'Like.ref_type' => '1', 'Like.type' => 'bookmark')));
			 $num_like = $this->Like->find('count', array('conditions' => array('Like.user_id' => $user_id, 'Like.ref_type' => '1', 'Like.type' => 'like')));
			
			$result = $this->Setting->find('first', array('fields' => array('val', 'key'), 'conditions' => array('Setting.key' => 'stats')));
			$badge = '';
			if(!empty($result))
			{				
				if(!empty($result['Setting']['val']))
				{
					$sval = unserialize($result['Setting']['val']);
					$point_review   = $sval['points']['review'];
					$point_bookmark = $sval['points']['bookmark'];
					$point_like     = $sval['points']['outlet_like'];	
					$total = ($num_bookmarks*$point_bookmark)+($point_review*$num_reviews)+($point_like*$num_like);					
				}					
				foreach($sval['batches'] as $batch_key => $row_batch)
				{
					if($total >= $row_batch['from'] && $total <= $row_batch['to'])
					{
						$badge = $row_batch['name'];
						break;
					}
				}
				$arr = array(							
								array('name' => 'Bookmark','point' => $point_bookmark, 'count' => $num_bookmarks, 'total' => $num_bookmarks*$point_bookmark),								
								array('name' => 'Outlet Likes','point' => $point_like,     'count' => $num_like, 'total' => $point_like*$num_like),
								array('name' => 'Reviews','point' => $point_review,   'count' => $num_reviews, 'total' => $point_review*$num_reviews),
							);
				$res_arr['results'] = $arr;			
				$res_arr['badge']   = $badge;
				$res_arr['total']   = $total;
				$res_arr['status']  = 1;
			}
			else
			{
				$res_arr['message'] =  'no record found';
				$res_arr['status'] =  0;
			}			
		}
		else
		{
			$res_arr['message'] =  'Invalid request';
			$res_arr['status'] =  0;
		}
		echo json_encode($res_arr);
		exit;
	}
	
	function emailVerification_()
	{
		print_r($_POST);die;
	}
	
	function emailVerification()
	{
		$jsonString = @file_get_contents("php://input");
		$this->request->data = json_decode(urldecode($jsonString),true);
		mail("pardeep@digiinteracts.com", "jsonData in while", $jsonString);
		App::uses('CakeEmail', 'Network/Email');
		$res_arr['status'] =  0;
		if(!empty($this->request->data))
		{
			$data = $this->formattedData($this->request->data);
			$mail = base64_encode($this->request->data['user_email']);
			$to = $this->request->data['user_email'];
			$Email = new CakeEmail();			
			$Email->template('email_verify');
			$Email->subject(__('Store Approval '));
			$Email->emailFormat('html');
			$Email->to($to);
			$Email->viewVars(array('email' => $mail,'user_email' => $this->request->data['user_email'], 'data' => $data));
			$Email->from('info@aasaan.ae');
			$a = $Email->send();
			$res_arr['message'] =  'Email has been sent successfully';
			$res_arr['status'] =  1;
		}
		else
		{
			$res_arr['message'] =  'Invalid request';
			$res_arr['status'] =  0;
		}
		echo json_encode($res_arr);
		exit;	
	}
	
	function formattedData($datas)
	{
		$output = array();
		foreach($datas as $k => $v)
		{			
			$output[$k] = $v;
			if(($k == 'timing1' || $k == 'timing2' || $k == 'timing3' || $k == 'timing4') && $v !=''){
				$output[$k]  = $this->CalculateTime($v);
			  }	
		  }
		   return $output;	  
	}
	
	function CalculateTime($v)
	{
		$output = '';
		$timing = json_decode($v,true);		
		if($v != '')
		{
			/*pr($timing['sat_thu']);die;
			$timing['sat_thu'] = json_decode($timing['sat_thu'],true);
			$timing['friday'] = json_decode($timing['friday'],true);*/
			
			if(isset($timing['sun_thu']))
			 {
				 $tm  = $timing['sun_thu'];					
				if($tm['avilable'] == 'yes')
				{
					$output = 'Sunday-Thursday : 24x7';
				}
				else
				{
					$tm['open_time'] = str_replace(array('AM','PM'), array('',''),$tm['open_time']);
					$tm['break_time'] = str_replace(array('AM','PM'), array('',''),$tm['break_time']);
					$open_time = explode('to', $tm['open_time']);
					$break_time = explode('to', $tm['break_time']);					
					$output = 'Sunday-Thursday :'.date('h:i A', strtotime($open_time[0])).' To '.date('h:i A', strtotime($break_time[0])).' , '.date('h:i A', strtotime($break_time[1])).' To '.date('h:i A', strtotime($open_time[1]));
				}
			 }
			
			 if(isset($timing[1]['friday']))
			 {
				 $tm  = $timing[1]['friday'];
				 if($tm['open'] == 'yes')
				 {
					if($tm['avilable'] == 'yes')
					{
						$output .= ' <br/> Friday : Open 24 Hours';
					}
					else
					{
						$tm['open_time']  = str_replace(array('AM','PM'), array('',''),$tm['open_time']);
						$tm['break_time'] = str_replace(array('AM','PM'), array('',''),$tm['break_time']);
						$open_time = explode('to', $tm['open_time']);
						$break_time = explode('to', $tm['break_time']);
						$output .= ' <br/> Friday : '.date('h:i A', strtotime($open_time[0])).' To '.date('h:i A', strtotime($break_time[0])).' , '.date('h:i A', strtotime($break_time[1])).' To '.date('h:i A', strtotime($open_time[1]));							
					}
				 }
				 else
				 {
					$output .= 'Friday : Close';
				 }				
			 } 
			  
			}
			return $output;
	}
	
	function getCityLandmark($city = null)
	{	
		$this->loadModel('Landmark');
		$result_landmark = $this->Landmark->find('list', array('fields' => array('id', 'title'), 'conditions' => array('city_id' => $city), 'order' => 'title'));
		if(empty($result_landmark))
		{
			$result_landmark = array();
		}
		$lan = array();
		$i = 0;
		if(!empty($result_landmark)){
			foreach($result_landmark as $k => $v){
				$lan[$i]['id'] = $k;
				$lan[$i]['name'] = $v;
				$i++;
			}
		}	
		$res_arr['landmark'] = $lan;
		$res_arr['status'] = 1;
		echo json_encode($res_arr);
		exit;
	}
		
	function getStateCityLandmark($city = null)
	{
		 
		if($city != null)
		{
			$this->loadModel('City');			
			$result_city = $this->City->find('list', array('fields' => array('id', 'title'), 'conditions' => array('state_id' => $city), 'order' => 'title'));
			if(empty($result_city))
			{
				$result_city = array();
			}
			
			$ct = array();
			$i = 0;
			foreach($result_city as $k => $v){
				$ct[$i]['id'] = $k;
				$ct[$i]['name'] = $v;
				$i++;
			}
			$res_arr['city'] = $ct;
		}
		else
		{
			$st  = Configure::read('ARR_STATES');
			$state = array();
			$i = 0;
			foreach($st as $k => $v){
				$state[$i]['id'] = $k;
				$state[$i]['name'] = $v;
				$i++;
			}
			$res_arr['state']  = $state;			
		}
		$res_arr['status'] = 1;
		echo json_encode($res_arr);
		exit;
	}
	
	function getPages($page_name)
	{
		$this->loadModel('Cms');
		$result_arr = $this->Cms->find('first', array('conditions' => array('Cms.url_key' => $page_name)));
		echo $result_arr['Cms']['content'];		
		exit;
	}
	
	function logout()
	{
		//$this->ApiConnect->check_valid_request($this->request);
		$res_arr = $result = array();
		if(!empty($this->request->data))
		{
			$user_info = $this->request->data;
			$register_user_email = $this->User->find('first', array('conditions' => array('id' => $user_info['UserId'])));
			if(!empty($register_user_email))
			{
					$data['User']['id'] = $register_user_email['User']['id'];
					$data['User']['device_token'] = '';
					$data['User']['device_token_i'] = '';
					$data['User']['join_ip'] = '';
					if($this->User->save($data))
					{
						$res_arr['message'] = 'Logout Successfully';
						$res_arr['status'] = 'success';
					}
					else
					{
						$res_arr['message'] = 'Logout faliure';
						$res_arr['status'] = 'faliure';
					}
			}
			else
			{
				$res_arr['message'] =  'Invalid user';
				$res_arr['status'] = 'faliure';
			}
		}
		else
		{
			$res_arr['message'] =  'Invalid request';
			$res_arr['status'] = 'faliure';
		}
		echo json_encode($res_arr);
		exit;
	}
	
}
