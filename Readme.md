# Exercise 1: Deploying an application using S2I & triggers

In this exercise, you'll deploy a simple Node.js Express application - "Example Health". Example Health is a simple UI for a patient health records system. We'll use this example to demonstrate key OpenShift features throughout this workshop. You can find the sample application GitHub repository here: [https://github.com/IBM/node-s2i-openshift](https://github.com/IBM/node-s2i-openshift)

## Deploy Example Health

Access your cluster on the [IBM Cloud clusters dashboard](https://cloud.ibm.com/kubernetes/clusters). Click the `OpenShift web console` button on the top-right. (This is a pop-up so you'll need to white list this site.)

Create a project, you can title it whatever you like, we suggest "example-health."

![Create Project](./assets/createproject.png)

Click on your new project. You should see a view that looks like this:

![Project View](./assets/projectview.png)

Click on the browse catalog button and scroll down to the `Node.js` image. Click on that catalog button.

![Node](./assets/node.png)

Click through to the second step for configuration, and choose `advanced options`. \( a blue hyperlink on the bottom line \)

![Advanced](./assets/advanced.png)

You'll see an advanced form like this:

![Node Advanced Form](./assets/node-advanced-form.png)

Enter the repository: `https://github.com/IBM/node-s2i-openshift` and `/site` for the 'Context Dir'. Click 'Create' at the bottom of the window to build and deploy the application.

Scroll through to watch the build deploying:

![Build](./assets/build.png)

When the build has deployed, click the 'External Traffic Route', and you should see the login screen like the following:

![Login](./assets/login.png)

You can enter any strings for username and password, for instance `test:test` because the app is running in demo mode.

Congrats! You've deployed a `Node.js` app to Kubernetes using OpenShift Source-to-Image (S2I).

## Understanding What Happened

[S2I](https://docs.openshift.com/container-platform/3.6/architecture/core_concepts/builds_and_image_streams.html#source-build) is a framework that creates container images from source code, then runs the assembled images as containers. It allows developers to build reproducible images easily, letting them spend time on what matters most, developing their code!

## Git Webhooks

So far we have been doing alot of manual deployment. In cloud-native world we want to move away from manual work and move toward automation. Wouldn't it be nice if our application rebuilt on git push events? Git webhooks are the way its done and openshift comes bundled in with git webhooks. Let's set it up for our project.

To be able to setup git webhooks, we need to have elevated permission to the project. We don't own the repo we have been using so far. But since its opensource we can easily fork it and make it our own.

Fork the repo at [https://github.com/IBM/node-s2i-openshift](https://github.com/IBM/node-s2i-openshift)

![Fork](./assets/fork.png)

Now that I have forked the repo under my repo I have full admin priviledges. As you can see I now have a settings button that I can change the repo settings with.

![Forked Repo](./assets/forked-repo.png)

We will come back to this page in a moment. Lets change our git source to our repo.

From our openshift dashboard for our project. Select `Builds > Builds`

![Goto Build](./assets/goto-build.png)

Select the patientui build. As of now this should be the only build on screen.

![Select Build](./assets/select-build.png)

Click on `Action` on the right and then select `Edit`

![Edit Build](./assets/edit-build.png)

Change the `Git Repository URL` to our forked repository.

Click Save in the bottom.

![Update Build](./assets/update-build-src.png)

You will see this will not result in a new build. If you want to start a manual build you can do so by clicking `Start Build`. We will skip this for now and move on to the webhook part.

Click on `Configuration` tab.

Copy the GitHub Webook URL.

The webhook is in the structure

```text
https://c100-e.us-east.containers.cloud.ibm.com:31305/apis/build.openshift.io/v1/namespaces/example-health/buildconfigs/patientui/webhooks/<secret>/github
```

![Copy github webhook](./assets/copy-github-webhook.png)

> There is also the generic webhook url. This also works for github. But the github webhook captures some additional data from github and is more specific. But if we were using some other git repo like bitbucket or gitlab we would use the generic one.

In our github repo go to `Setting > Webhooks`. Then click `Add Webhook`

![webhook page](./assets/webhook-page.png)

In the Add Webhook page fill in the `Payload URL` with the url copied earlier from the build configuration. Change the `Content type` to `application/json`.

> **NOTE**: The *Secret* field can remain empty.

Right now just the push event is being sent which is fine for our use.

Click on `Add webhook`

![add webhook](./assets/add-webhook.png)

If the webhook is reachable by github you will see a green check mark.

Back in our openshift console we still would only see one build however. Because we added a webhook that sends us push events and we have no push event happening. Lets make one. The easiest way to do it is probably from the Github UI. Lets change some text in the login page.

Path to this file is `site/public/login.html` from the root of the directory. On Github you can edit any file by clicking the Pencil icon on the top right corner.

![edit page](./assets/edit-page.png)

Let's change the name our application to `Demo Health` (Line 21, Line 22). Feel free to make any other UI changes you feel like.

![changes](./assets/changes.png)

Once done go to the bottom and click `commit changes`.

Go to the openshift build page again. This happens quite fast so you might not see the running state. But the moment we made that commit a build was kicked off.

![running build](../assets/running-build.png)

In a moment it will show completed. Navigate to the overview page to find the route.

![route](./assets/route.png)

> You could also go to `Applications > Routes` to find the route for the application.

If you go to your new route you will see your change.

![UI](./assets/updated-ui.png)

# Exercise 2: Understand Buildconfig Strategy Options
##What Is a Build?
A build in OpenShift Container Platform is the process of transforming input parameters into a resulting object. Most often, builds are used to transform source code into a runnable container image.
A build configuration, or BuildConfig, is characterized by a build strategy and one or more sources. The strategy determines the aforementioned process, while the sources provide its input.
The build strategies are:
* Source-to-Image (S2I) (description, options)
* Pipeline (description, options)
* Docker (description, options)
* Custom (description, options)

And there are six types of sources that can be given as build input:
* Git
* Dockerfile
* Binary
* Image
* Input secrets
* External artifacts

#BuildConfig Object Definition
We can check our health application to explore the BuildConfig object.
Go back to your openshift console and click on 'Builds'

![UI](./assets/gotobuildwindow.png)

Select the application build

![UI](./assets/selectourappbuild.png)

Go to 'Configuration' and click on 'Actions' -> 'Edit YAML'

![UI](./assets/configurationedityaml.png)

* This specification will create a new BuildConfig named patientui.
* The postCommit section defines an optional build hook.
* The runPolicy field controls whether builds created from this build configuration can be run simultaneously. The default value is Serial, which means new builds will run sequentially, not simultaneously.
* The strategy section describes the build strategy used to execute the build. You can specify a Source , Docker, or Custom strategy here. This above example uses the nodejs:10 container image that Source-To-Image will use for the application build.
* The source section defines the source of the build. The source type determines the primary source of input, and can be either Git, to point to a code repository location, Dockerfile, to build from an inline Dockerfile, or Binary, to accept binary payloads. It is possible to have multiple sources at once, refer to the documentation for each source type for details.
* You can specify a list of triggers, which cause a new build to be created.

![UI](./assets/buildconfigyaml.png)



